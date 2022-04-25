import 'dart:convert';

import 'package:Stuff_Pages/request/entities/achievement.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../navigator.dart';

class ShowTrophy extends StatefulWidget {
  Game game;

  ShowTrophy(Game game) {
    this.game = game;
  }

  @override
  _ShowTrophyState createState() => _ShowTrophyState(game);
}

class _ShowTrophyState extends State<ShowTrophy> {
  Game game;
  bool donefilter = false;
  List<Achievement> _achievements = [];
  List<Achievement> filteredAchievments = [];
  final String secretTitle = "Hidden Trophy";
  final String secretDescription = "";

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
      activeTrackColor: addedColor,
      activeColor: addedColor,
      inactiveTrackColor: cardBackgroundColor,
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

  _getTrophies() {
    filteredAchievments.clear();
    final endpoint = "achievements/game=" + game.gameId;
    Api.get(endpoint).then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _achievements = list.map((e) => Achievement.fromJson(e)).toList();
        _achievements.sort((a, b) => a.title.compareTo(b.title));
        filteredAchievments.addAll(_achievements);
        donefilter = game.earned != null && (game.earned / game.sum * 100) == 100;
        filter();
      });
    });
  }

  initState() {
    super.initState();
    _getTrophies();
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text(game.title, style: TextStyle(color: fontColor)),
          actions: <Widget>[doneFilter()]),
      body: Center(
        child: Column(
          children: <Widget>[Expanded(child: _trophyList())],
        ),
      ),
      bottomNavigationBar: MyNavigator(3),
      backgroundColor: backgroundColor,
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
              color: cardBackgroundColor,
            ),
            onDismissed: (direction) {
              Fluttertoast.showToast(
                  msg: item.title,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: item.earned ? deleteColor : addedColor,
                  fontSize: 16.0);
              setState(() {
                item.earned = !item.earned;
                Api.put('achievements/', item, item.id);
                filter();
              });
            },
            background:
                Container(color: item.earned ? deleteColor : addedColor),
          ),
          onTap: () {
            launchURL(game.title + " " + item.title);
          },
        );
      },
    );
  }

  Widget getTrophy(Achievement trophy) {
    final secret = trophy.secret;
    final earned = trophy.earned;
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
          title: secret && !earned ? Text(secretTitle, style: TextStyle(color: fontColor)) : Text(trophy.title, style: TextStyle(color: fontColor)),
          subtitle: secret && !earned
              ? Text(secretDescription, style: TextStyle(color: fontColor))
              : Text(trophy.description, style: TextStyle(color: fontColor)),
          trailing: showButton(trophy),
          onTap: () {
            launchURL(game.title + " " + trophy.title);
          },
        ),
      ],
    );
  }

  Widget showButton(Achievement achievement) {
    if (achievement.secret) {
      return IconButton(
          icon: achievement.show
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
              achievement.show = !achievement.show;
            });
          });
    }
    return null;
  }
}
