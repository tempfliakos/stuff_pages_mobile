import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stuff_pages/request/entities/achievement.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/gameUtil.dart';

import '../navigator.dart';

class ShowAchievement extends StatefulWidget {
  Game game = new Game();

  ShowAchievement(Game game) {
    this.game = game;
  }

  @override
  _ShowAchievementState createState() => _ShowAchievementState(game);
}

class _ShowAchievementState extends State<ShowAchievement> {
  Game game = new Game();
  bool donefilter = false;
  List<Achievement> _achievements = [];
  List<Achievement> filteredAchievments = [];
  final String secretTitle = "Secret achievement";
  final String secretDescription =
      "This achievement is secret. The more you play, the more likely you are to unlock it!";

  _ShowAchievementState(Game game) {
    this.game = game;
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
    filteredAchievments.clear();
    filteredAchievments.addAll(_achievements);
    _achievements.forEach((achievement) {
      if (!achievement.earned! == donefilter) {
        filteredAchievments.remove(achievement);
      }
    });
    setState(() {});
  }

  _getAchievements() {
    filteredAchievments.clear();
    final endpoint = "achievements/game=" + game.gameId!;
    Api.get(endpoint).then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _achievements = list.map((e) => Achievement.fromJson(e)).toList();
        _achievements.sort((a, b) => a.title!.compareTo(b.title!));
        filteredAchievments.addAll(_achievements);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text(game.title!, style: TextStyle(color: fontColor)),
          actions: <Widget>[starButton(), doneFilter()]),
      body: Center(
        child: Column(
          children: <Widget>[Expanded(child: _achievementList())],
        ),
      ),
      bottomNavigationBar: MyNavigator(2),
      backgroundColor: backgroundColor,
    );
  }

  Widget _achievementList() {
    return ListView.builder(
      itemCount: filteredAchievments.length,
      itemBuilder: (context, index) {
        final item = filteredAchievments[index];
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
            setState(() {
              achievement.earned = !achievement.earned!;
              Api.put('achievements/', achievement, achievement.id);
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
