import 'dart:convert';

import 'package:Stuff_Pages/playstation/addpsgame.dart';
import 'package:Stuff_Pages/playstation/trophylist.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import '../enums/gamesEnum.dart';
import '../global.dart';
import '../navigator.dart';

class PsList extends StatefulWidget {
  @override
  _PsListState createState() => _PsListState();
}

class _PsListState extends State<PsList> {
  ScrollController controller;
  List<Game> _games = [];
  List<Game> _starred = [];
  String titleFilter = "";
  int pageNumber = 1;
  int maxPageNumber;

  _getPsGames() {
    Api.get("games/console=Playstation&page=$pageNumber&title=$titleFilter")
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
        } catch (e) {
          print(e);
        }
        ProgressHud.dismiss();
      });
    });
  }

  _getStarGames() {
    Api.get("games/star/console=Playstation").then((res) {
      setState(() {
        try {
          List<dynamic> data = json.decode(res.body);
          _starred = data.map((e) => Game.starFromJson(e)).toList();
        } catch (e) {
          print(e);
        }
        ProgressHud.dismiss();
      });
    });
  }

  initState() {
    super.initState();
    _getPsGames();
    _getStarGames();
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
    _getPsGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: backgroundColor,
          title: Text("Playstation játékok listája"),
          actions: <Widget>[optionsButton(), logoutButton()]),
      body: Scrollbar(
        child: Center(
          child: Column(
            children: <Widget>[
              getStarList(),
              filterTitleField(),
              Expanded(child: _gameList())
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddPsGame(_games)));
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: addedColor,
      ),
      bottomNavigationBar: MyNavigator(3),
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
            child: getGame(item, starButton(item)),
            color: cardBackgroundColor,
          ),
          onTap: () => openTrophies(item),
        );
      },
    );
  }

  Widget getStarList() {
    if (_starred.isNotEmpty) {
      return Container(
          child: _starList(),
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.all(20.0));
    }
    return Text("");
  }

  Widget _starList() {
    List<Widget> highlights = [];
    for (Game starred in _starred) {
      highlights.add(new GestureDetector(
        onTap: () => openTrophies(starred),
        child: highlightImg(starred),
      ));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: highlights,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }

  Widget starButton(Game game) {
    return IconButton(
        icon: Icon(
          game.star ? Icons.star : Icons.star_border,
          color: futureColor,
        ),
        onPressed: () {
          setState(() {
            game.star = !game.star;
            Api.put("games/", game, game.id);
            if (game.star) {
              _starred.add(game);
            } else {
              _starred.removeWhere((g) => g.id == game.id);
            }
          });
        });
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
      _getPsGames();
    }
  }

  openTrophies(Game game) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ShowTrophy(game)));
    _getPsGames();
  }
}
