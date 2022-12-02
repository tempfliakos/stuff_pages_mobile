import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stuff_pages/enums/searchEnum.dart';
import 'package:stuff_pages/request/entities/achievement.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/gameUtil.dart';

import '../navigator.dart';

class ShowTrophy extends StatefulWidget {
  late Game game;

  ShowTrophy(Game game) {
    this.game = game;
  }

  @override
  _ShowTrophyState createState() => _ShowTrophyState(game);
}

class _ShowTrophyState extends State<ShowTrophy> {
  late Game game;
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
      if (!achievement.earned! == donefilter) {
        filteredAchievments.remove(achievement);
      }
    });
    setState(() {});
  }

  _getTrophies() {
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
          title: Text(game.title!, style: TextStyle(color: fontColor)),
          actions: <Widget>[starButton(), doneFilter()]),
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
        return Slidable(
            key: UniqueKey(),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [youtubeButton(game, item), googleButton(game, item)],
            ),
            child: InkWell(
              child: Card(
                child: getTrophy(item),
                color: cardBackgroundColor,
              ),
            ));
      },
    );
  }

  Widget getTrophy(Achievement trophy) {
    final secret = trophy.secret! && !trophy.show!;
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
          title: secret && !earned!
              ? Text(secretTitle, style: TextStyle(color: fontColor))
              : Text(trophy.title!, style: TextStyle(color: fontColor)),
          subtitle: secret && !earned!
              ? Text(secretDescription, style: TextStyle(color: fontColor))
              : Text(trophy.description!, style: TextStyle(color: fontColor)),
          trailing: showButton(trophy),
          onLongPress: () {
            setState(() {
              trophy.earned = !trophy.earned!;
              Api.put('achievements/', trophy, trophy.id);
              filter();
            });
          },
        ),
      ],
    );
  }

  Widget? showButton(Achievement trophy) {
    if (trophy.secret! && !trophy.earned!) {
      return IconButton(
          icon: trophy.show!
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
              trophy.show = !trophy.show!;
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
