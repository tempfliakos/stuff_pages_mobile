import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stuff_pages/request/entities/achievement.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/basicUtil.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/gameUtil.dart';

import '../global.dart';

class ShowAchievement extends StatefulWidget {
  late final Game game;
  late final String secretTitle;
  late final String secretDescription;

  ShowAchievement(Game game, String secretTitle, String secretDescription) {
    this.game = game;
    this.secretTitle = secretTitle;
    this.secretDescription = secretDescription;
  }

  @override
  _ShowAchievementState createState() =>
      _ShowAchievementState(game, secretTitle, secretDescription);
}

class _ShowAchievementState extends State<ShowAchievement> {
  late Game game;
  late String secretTitle;
  late String secretDescription;
  String titleFilter = "";
  bool filterMode = false;
  bool doneFilter = false;
  List<Achievement> _achievements = [];
  List<Achievement> filteredAchievements = [];

  _ShowAchievementState(
      Game game, String secretTitle, String secretDescription) {
    this.game = game;
    this.secretTitle = secretTitle;
    this.secretDescription = secretDescription;
  }

  filter() {
    filteredAchievements.clear();
    filteredAchievements.addAll(_achievements);
    _achievements.forEach((achievement) {
      if (!achievement.title!
          .toLowerCase()
          .contains(titleFilter.toLowerCase())) {
        filteredAchievements.remove(achievement);
      }
    });
    setState(() {});
  }

  _getAchievements() {
    filteredAchievements.clear();
    final endpoint = "achievements/game=" + game.id!;
    Api.get(endpoint).then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _achievements = list.map((e) => Achievement.fromJson(e)).toList();
        _achievements.sort((a, b) =>
            removeDiacritics(a.title!).compareTo(removeDiacritics(b.title!)));
        filteredAchievements.addAll(_achievements);
        doneFilter =
            game.earned != null && (game.earned! / game.sum! * 100) == 100;
        filter();
      });
    });
  }

  initState() {
    super.initState();
    _getAchievements();
  }

  dispose() {
    super.dispose();
  }

  void titleField(String text) {
    titleFilter = text;
    filter();
  }

  @override
  Widget build(BuildContext context) {
    if (doneFilter) {
      return doneScreen();
    }
    return inProgressScreen();
  }

  Widget inProgressScreen() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: backgroundColor,
            title: titleWidget(),
            actions: <Widget>[
              filterButton(doFilterChange),
              starButton(),
            ],
            bottom: TabBar(
              indicatorColor: futureColor,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(filterByEarned(false).length.toString(), style: TextStyle(color: fontColor, fontSize: 20)),
                      const SizedBox(width: 8),
                      Icon(Icons.lock_outlined, color: fontColor)
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(filterByEarned(true).length.toString(), style: TextStyle(color: fontColor, fontSize: 20)),
                      const SizedBox(width: 8),
                      Icon(Icons.lock_open_outlined, color: fontColor)
                    ],
                  ),
                ),
              ],
            )),
        body: TabBarView(
          children: [
            _tabContent(false),
            _tabContent(true),
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget doneScreen() {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: backgroundColor,
          title: titleWidget(),
          actions: <Widget>[
            filterButton(doFilterChange),
            starButton(),
          ]),
      body: _tabContent(true),
      backgroundColor: backgroundColor,
    );
  }

  Widget titleWidget() {
    if (!filterMode) {
      return Text(game.title!, style: TextStyle(color: fontColor));
    } else {
      return searchBar("Cím", titleField);
    }
  }

  void doFilterChange() {
    setState(() {
      filterMode = !filterMode;
    });
  }

  Widget _tabContent(bool earned) {
    return Center(
      child: Column(
        children: <Widget>[Expanded(child: _achievementList(earned))],
      ),
    );
  }

  Widget _achievementList(bool earned) {
    return ListView.builder(
      itemCount: filterByEarned(earned).length,
      itemBuilder: (context, index) {
        final item = filterByEarned(earned)[index];
        return Slidable(
            key: UniqueKey(),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [youtubeButton(game, item), googleButton(game, item)],
            ),
            child: InkWell(
              child: Card(
                child: getAchievement(item),
                color: cardBackgroundColor,
              ),
            ));
      },
    );
  }

  filterByEarned(bool earned) {
    return filteredAchievements
        .where((element) => element.earned! == earned)
        .toList();
  }

  Widget getAchievement(Achievement achievement) {
    final secret = achievement.secret! && !achievement.show!;
    final earned = achievement.earned;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 44,
                minHeight: 44,
                maxWidth: 200,
                maxHeight: 200,
              ),
              child: achievementImg(achievement)),
          title: secret && !earned!
              ? Text(secretTitle, style: TextStyle(color: fontColor))
              : Text(achievement.title!, style: TextStyle(color: fontColor)),
          subtitle: secret && !earned!
              ? Text(secretDescription, style: TextStyle(color: fontColor))
              : Text(achievement.description!,
                  style: TextStyle(color: fontColor)),
          trailing: showButton(achievement),
          onTap: () {
            if (achievement.secret!) {
              setState(() {
                achievement.show = !achievement.show!;
              });
            }
          },
          onLongPress: () {
            setState(() {
              achievement.earned = !achievement.earned!;
              Api.put('achievements/', achievement, achievement.id);
              if (achievement.earned!) {
                showToast(context, achievement.title! + " kész!");
              } else {
                showToast(context, achievement.title! + " még hátravan!");
              }
              filter();
            });
          },
        ),
      ],
    );
  }

  Widget? showButton(Achievement achievement) {
    if (achievement.secret! && !achievement.earned!) {
      return IconButton(
          icon: achievement.show!
              ? Icon(
                  Icons.lock_open_outlined,
                  color: fontColor,
                )
              : Icon(
                  Icons.lock_outlined,
                  color: fontColor,
                ),
          onPressed: () {
            setState(() {
              achievement.show = !achievement.show!;
            });
          });
    }
    return null;
  }

  Widget starButton() {
    return IconButton(
        icon: Icon(
          game.star! ? Icons.star : Icons.star_border,
          color: futureColor,
        ),
        onPressed: () {
          setState(() {
            game.star = !game.star!;
            Api.put("games/", game, game.id);
          });
        });
  }
}
