import 'dart:convert';

import 'package:Stuff_Pages/request/entities/achievement.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';

class ShowTrophy extends StatefulWidget {
  var game;

  ShowTrophy(Game game) {
    this.game = game;
  }

  @override
  _ShowTrophyState createState() => _ShowTrophyState(game);
}

class _ShowTrophyState extends State<ShowTrophy> {
  var game;
  var donefilter = false;
  List _achievements = new List<Achievement>();
  List filteredAchievments = new List<Achievement>();

  _ShowTrophyState(Game game) {
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
          children: <Widget>[Expanded(child: _trophyList())],
        ),
      ),
      bottomNavigationBar: MyNavigator(),
      backgroundColor: Colors.grey,
    );
  }

  Widget _trophyList() {
    return ListView.builder(
      itemCount: filteredAchievments.length,
      itemBuilder: (context, index) {
        final item = filteredAchievments[index];
        return InkWell(
          child: Dismissible(
            key: UniqueKey(),
            child: Card(
              child: getTrophy(item),
              color: Colors.grey,
            ),
            onDismissed: (direction) {
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(item.title +
                      (item.earned ? ' nincs kész' : ' kész'))));
              setState(() {
                item.earned = !item.earned;
                Api.put('achievements/', item, item.id);
                filter();
              });
            },
            background: Container(color: item.earned ? Colors.red : Colors.green),
          ),
          onTap: () {
            launchURL(game.title + " " + item.title);
          },
        );
      },
    );
  }

  Widget getTrophy(Achievement trophy) {
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
              child: trophyImg(trophy)),
          title: Text(trophy.title),
          subtitle: Text(trophy.description),
        ),
      ],
    );
  }
}
