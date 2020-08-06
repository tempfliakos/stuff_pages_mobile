import 'dart:convert';

import 'package:Stuff_Pages/request/entities/achievement.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';

class ShowAchievement extends StatefulWidget {
  var game;

  ShowAchievement(Game game) {
    this.game = game;
  }

  @override
  _ShowAchievementState createState() => _ShowAchievementState(game);
}

class _ShowAchievementState extends State<ShowAchievement> {
  var game;
  var donefilter = false;
  List _achievements = new List<Achievement>();
  List filteredAchievments = new List<Achievement>();

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
      activeTrackColor: Colors.blue,
      activeColor: Colors.blue,
      inactiveTrackColor: Colors.grey,
    );
  }

  filter() {
    filteredAchievments.clear();
    filteredAchievments.addAll(_achievements);
    _achievements.forEach((achievement) {
      if (!achievement.earned == donefilter) {
        filteredAchievments.remove(achievement);
      }
    });
    setState(() {});
  }

  _getAchievements() {
    filteredAchievments.clear();
    final user =
        'user=' + userStorage.getItem('user') + "&" + 'game_id=${game.gameId}';
    Api.get("achievements/", user).then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _achievements = list.map((e) => Achievement.fromJson(e)).toList();
        _achievements.sort((a, b) => a.title.compareTo(b.title));
        filteredAchievments.addAll(_achievements);
        donefilter = (game.earned / game.sum * 100) == 100;
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
      appBar: AppBar(title: Text(game.title), actions: <Widget>[doneFilter()]),
      body: Center(
        child: Column(
          children: <Widget>[Expanded(child: _achievementList())],
        ),
      ),
      bottomNavigationBar: MyNavigator(),
      backgroundColor: Colors.grey,
    );
  }

  Widget _achievementList() {
    return ListView.builder(
      itemCount: filteredAchievments.length,
      itemBuilder: (context, index) {
        final item = filteredAchievments[index];
        return InkWell(
          child: Card(
            child: getAchievement(item),
            color: Colors.grey,
          ),
          onTap: () {
            setState(() {
              item.earned = !item.earned;
              Api.put('achievements/', item, item.id);
              filter();
            });
          },
        );
      },
    );
  }

  Widget getAchievement(Achievement achievement) {
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
          title: Text(achievement.title),
          subtitle: Text(achievement.description),
        ),
      ],
    );
  }
}
