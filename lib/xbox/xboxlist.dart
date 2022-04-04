import 'dart:convert';

import 'package:Stuff_Pages/enums/gamesEnum.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';
import 'achievementlist.dart';
import 'addxboxgame.dart';

class XboxList extends StatefulWidget {
  @override
  _XboxListState createState() => _XboxListState();
}

class _XboxListState extends State<XboxList> {
  ScrollController controller;
  List<Game> _games = [];
  String titleFilter = "";
  int pageNumber = 1;
  int maxPageNumber;

  _getXboxGames() {
    Api.get("games/console=Xbox&page=$pageNumber&title=$titleFilter")
        .then((res) {
      setState(() {
        try {
          Map<String, dynamic> data = json.decode(res.body);
          Iterable list = data[GamesEnum.games.name];
          maxPageNumber = (data[GamesEnum.count.name] / list.length).ceil();
          List<Game> games = list.map((e) => Game.fromJson(e)).toList();
          List<String> _gamesIds = games.map((e) => e.gameId).toList();
          _games = _games.where((g) => !_gamesIds.contains(g.gameId)).toList();
          _games.addAll(createFinalGameList(games));
        } catch (e) {}
        ProgressHud.dismiss();
      });
    });
  }

  initState() {
    super.initState();
    _getXboxGames();
    controller = ScrollController()..addListener(_scrollListener);
  }

  dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  Widget filterTitleField() {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.black),
      child: TextField(
        decoration: InputDecoration(
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            labelText: 'Játék címe...'),
        onChanged: (text) {
          titleFilter = text;
          filter();
        },
        cursorColor: Colors.white,
        autofocus: false,
      ),
    );
  }

  void filter() {
    pageNumber = 1;
    _games = [];
    _getXboxGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Text("Xbox játékok listája"),
          actions: <Widget>[optionsButton(), logoutButton()]),
      body: Scrollbar(
        child: Center(
          child: Column(
            children: <Widget>[
              filterTitleField(),
              Expanded(child: _gameList())
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddXboxGame(_games)));
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: MyNavigator(2),
      backgroundColor: Colors.grey,
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
            color: Colors.grey,
          ),
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => ShowAchievement(item)));
            _getXboxGames();
          },
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
              child: xboxImg(game)),
          title: Text(game.title),
          subtitle: Text(calculatePercentage(game)),
          trailing: starButton(game),
        ),
      ],
    );
  }

  Widget starButton(Game game) {
    return IconButton(
        icon: Icon(
          game.star ? Icons.star : Icons.star_border,
          color: Colors.amber,
        ),
        onPressed: () {
          setState(() {
            game.star = !game.star;
            Api.put("games/", game, game.id);
          });
        });
  }

  Widget logoutButton() {
    return IconButton(
        icon: Icon(
          Icons.power_settings_new,
          color: Colors.red,
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
          color: Colors.grey,
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
      _getXboxGames();
    }
  }
}
