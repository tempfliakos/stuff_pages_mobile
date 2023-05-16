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
  bool donefilter = false;
  String titleFilter = "";
  bool filterMode = false;
  List<Achievement> _achievements = [];
  List<Achievement> filteredAchievements = [];

  _ShowAchievementState(
      Game game, String secretTitle, String secretDescription) {
    this.game = game;
    this.secretTitle = secretTitle;
    this.secretDescription = secretDescription;
  }

  Widget doneFilter() {
    return Switch(
      value: donefilter,
      onChanged: (value) {
        setState(() {
          donefilter = value;
          filter();
        });
      },
      activeTrackColor: addedColor,
      activeColor: addedColor,
      inactiveTrackColor: cardBackgroundColor,
    );
  }

  filter() {
    filteredAchievements.clear();
    filteredAchievements.addAll(_achievements);
    _achievements.forEach((achievement) {
      if (!achievement.earned! == donefilter ||
          !achievement.title!.toLowerCase().contains(titleFilter.toLowerCase())) {
        filteredAchievements.remove(achievement);
      }
    });
    setState(() {});
  }

  _getAchievements() {
    filteredAchievements.clear();
    final endpoint = "achievements/game=" + game.gameId!;
    Api.get(endpoint).then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _achievements = list.map((e) => Achievement.fromJson(e)).toList();
        _achievements.sort((a, b) =>
            removeDiacritics(a.title!).compareTo(removeDiacritics(b.title!)));
        filteredAchievements.addAll(_achievements);
        donefilter =
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
    return Scaffold(
      appBar: AppBar(
          backgroundColor: backgroundColor,
          title: titleWidget(),
          actions: <Widget>[
            filterButton(doFilterChange),
            starButton(),
            doneFilter()
          ]),
      body: Center(
        child: Column(
          children: <Widget>[Expanded(child: _achievementList())],
        ),
      ),
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

  Widget _achievementList() {
    return ListView.builder(
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final item = filteredAchievements[index];
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
