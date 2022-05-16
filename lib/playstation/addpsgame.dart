import 'dart:convert';

import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import '../global.dart';

class AddPsGame extends StatefulWidget {
  @override
  _AddPsGameState createState() => _AddPsGameState();
}

class _AddPsGameState extends State<AddPsGame> {
  List<Game> addGames = [];
  List<Game> games = [];
  String queryString = "";

  _AddPsGameState() {
    Api.get("games/ids/console=Playstation")
        .then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        games = list.map((e) => Game.addScreen(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: searchBar("Játék hozzáadása...", searchField, false),
        actions: [
          searchIcon()
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _gameList()),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  void searchField(String text) {
    queryString = text;
  }

  IconButton searchIcon() {
    return IconButton(
        icon: Icon(
          Icons.search,
          color: fontColor,
        ),
        onPressed: () => findGames());
  }

  void findGames() {
    if (queryString.length > 2) {
      ProgressHud.showLoading();
      Api.getFromApi("playstation", queryString.toString()).then((res) {
        if (res != null) {
          List<dynamic> result = json.decode(res.body);
          setState(() {
            addGames.clear();
            result.forEach((game) {
              addGames.add(Game.addFromJson(game));
            });
          });
        }
        ProgressHud.dismiss();
      });
    } else {
      addGames.clear();
    }
  }

  Widget _gameList() {
    return ListView.builder(
        itemCount: addGames.length,
        itemBuilder: (context, index) {
          final item = addGames[index];
          return InkWell(
              child: Card(
            child: getGame(item, addButton(item)),
            color: cardBackgroundColor,
          ));
        });
  }

  Widget addButton(Game game) {
    if (games.map((e) => e.gameId).toList().contains(game.gameId)) {
      return IconButton(
        icon: Icon(
          Icons.check_circle,
          color: addedColor,
        ),
        onPressed: () {},
      );
    } else {
      return IconButton(
          icon: Icon(
            Icons.check_circle_outline,
            color: addableColor,
          ),
          onPressed: () {
            setState(() {
              final body = game.toJson();
              games.add(game);
              Api.post('games', body);
            });
          });
    }
  }
}
