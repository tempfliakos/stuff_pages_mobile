import 'dart:convert';

import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import '../enums/gamesEnum.dart';
import '../global.dart';
import '../navigator.dart';
import 'addswitchgame.dart';

class SwitchList extends StatefulWidget {
  @override
  _SwitchListState createState() => _SwitchListState();
}

class _SwitchListState extends State<SwitchList> {
  ScrollController controller;
  List<Game> _games = [];
  String titleFilter = "";
  int pageNumber = 1;
  int maxPageNumber;
  bool filterMode = false;

  _getSwitchGames() {
    Api.get("games/console=Switch&page=$pageNumber&title=$titleFilter")
        .then((res) {
      setState(() {
        Map<String, dynamic> data = json.decode(res.body);
        Iterable list = data[GamesEnum.games.name];
        maxPageNumber = (data[GamesEnum.count.name] / list.length).ceil();
        List<Game> games = list.map((e) => Game.fromJson(e)).toList();
        List<String> _gamesIds = games.map((e) => e.gameId).toList();
        _games = _games.where((g) => !_gamesIds.contains(g.gameId)).toList();
        _games.addAll(createFinalGameList(games));
      });
    });
  }

  initState() {
    super.initState();
    _getSwitchGames();
    controller = ScrollController()..addListener(_scrollListener);
  }

  dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void titleField(String text) {
    titleFilter = text;
    filter();
  }

  void filter() {
    pageNumber = 1;
    _games = [];
    _getSwitchGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: backgroundColor,
          title: titleWidget(),
          actions: <Widget>[
            filterButton(doFilterChange),
            optionsButton(doOptions),
            logoutButton(doLogout)
          ]),
      body: Center(
        child: Column(
          children: <Widget>[Expanded(child: _gameList())],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddSwitchGame(_games)));
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: addedColor,
      ),
      bottomNavigationBar: MyNavigator(4),
      backgroundColor: backgroundColor,
    );
  }

  Widget titleWidget() {
    if (!filterMode) {
      return Text('Switch játékok listája', style: TextStyle(color: fontColor));
    } else {
      return searchBar("Játék címe", titleField);
    }
  }

  Widget _gameList() {
    return ListView.builder(
      controller: controller,
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final item = _games[index];
        return InkWell(
          child: Card(
            child: getGame(item, null),
            color: cardBackgroundColor,
          ),
        );
      },
    );
  }

  void _scrollListener() {
    if (maxPageNumber >= pageNumber && controller.position.extentAfter == 0) {
      ProgressHud.showLoading();
      pageNumber++;
      _getSwitchGames();
    }
  }
  void doFilterChange() {
    setState(() {
      filterMode = !filterMode;
    });
  }

  void doLogout() {
    setState(() {
      resetStorage();
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void doOptions() {
    setState(() {
      Navigator.pushReplacementNamed(context, '/options');
    });
  }
}
