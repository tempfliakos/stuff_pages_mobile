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

  Widget filterTitleField() {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: cardBackgroundColor),
      child: TextField(
        decoration: InputDecoration(
            fillColor: cardBackgroundColor,
            border: OutlineInputBorder(),
            labelText: 'Játék címe...'),
        onChanged: (text) {
          titleFilter = text;
          filter();
        },
        cursorColor: cardBackgroundColor,
        autofocus: false,
      ),
    );
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
          title: Text("Switch játékok listája"),
          actions: <Widget>[optionsButton(), logoutButton()]),
      body: Center(
        child: Column(
          children: <Widget>[filterTitleField(), Expanded(child: _gameList())],
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

  Widget _gameList() {
    return ListView.builder(
      controller: controller,
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final item = _games[index];
        return InkWell(
          child: Card(
            child: getGame(item),
            color: cardBackgroundColor,
          ),
        );
      },
    );
  }

  Widget getGame(game) {
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
                child: img(game)),
            title: Text(game.title)),
      ],
    );
  }

  Widget logoutButton() {
    return IconButton(
        icon: Icon(
          Icons.power_settings_new,
          color: deleteColor,
        ),
        onPressed: () {
          setState(() {
            userStorage.deleteItem('user');
            userStorage.deleteItem('options');
            Navigator.pushReplacementNamed(context, '/');
          });
        });
  }

  Widget optionsButton() {
    return IconButton(
        icon: Icon(
          Icons.settings,
          color: cardBackgroundColor,
        ),
        onPressed: () {
          setState(() {
            Navigator.pushReplacementNamed(context, '/options');
          });
        });
  }

  void _scrollListener() {
    if (maxPageNumber >= pageNumber && controller.position.extentAfter == 0) {
      ProgressHud.showLoading();
      pageNumber++;
      _getSwitchGames();
    }
  }
}
