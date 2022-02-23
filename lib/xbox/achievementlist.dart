import 'dart:convert';

import 'package:Stuff_Pages/request/entities/achievement.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  List _achievements = [];
  List filteredAchievments = [];
  final secretTitle = "Secret achievement";
  final secretDescription =
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
    final endpoint = "achievements/game=" + game.gameId;
    Api.get(endpoint).then((res) {
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
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(game.title),
          actions: <Widget>[refreshButton(), doneFilter()]),
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
          child: Dismissible(
            key: UniqueKey(),
            child: Card(
              child: getAchievement(item),
              color: Colors.grey,
            ),
            onDismissed: (direction) {
              Fluttertoast.showToast(
                  msg: item.title,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: item.earned ? Colors.red : Colors.green,
                  fontSize: 16.0);
              setState(() {
                item.earned = !item.earned;
                Api.put('achievements/', item, item.id);
                filter();
              });
            },
            background:
                Container(color: item.earned ? Colors.red : Colors.green),
          ),
          onLongPress: () {
            Fluttertoast.showToast(
                msg: item.title + " ( " + item.description + " )",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.grey,
                fontSize: 16.0);
          },
        );
      },
    );
  }

  Widget getAchievement(Achievement achievement) {
    final secret = achievement.secret;
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
          title:
              secret && !earned ? Text(secretTitle) : Text(achievement.title),
          subtitle: secret && !earned
              ? Text(secretDescription)
              : Text(achievement.description),
          onTap: () {
            launchURL(game.title + " " + achievement.title);
          },
        ),
      ],
    );
  }

  Widget refreshButton() {
    return IconButton(
        icon: Icon(
          Icons.refresh,
          color: Colors.yellow,
        ),
        onPressed: () {
          setState(() {
            var endpoint = 'achievements/game=' + this.game.gameId;
            Api.post(endpoint, []);
            initState();
          });
        });
  }
}
