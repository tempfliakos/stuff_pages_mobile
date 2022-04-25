import 'dart:convert';

import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddWishGame extends StatefulWidget {
  List<Game> addGames = [];
  List<Game> games = [];

  AddWishGame(List<Game> games) {
    this.games = games;
  }

  @override
  _AddWishGameState createState() => _AddWishGameState(games);
}

class _AddWishGameState extends State<AddWishGame> {
  List<Game> addGames = [];
  List<Game> games = [];
  String queryString = "";

  _AddWishGameState(List<Game> games) {
    this.games = games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Játékok hozzáadása", style: TextStyle(color: fontColor)),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            findGameField(),
            Expanded(child: _gameList()),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget findGameField() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Játék keresése...',
          ),
          onChanged: (text) {
            queryString = text;
          },
        ),
        TextButton(
            child: Text("Keresés", style: TextStyle(color: fontColor)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(addedColor)),
            onPressed: () {
              findGames();
            })
      ],
    );
  }

  void findGames() {
    if (queryString.length > 2) {
      Api.getFromApi("wish", queryString.toString()).then((res) {
        if (res != null) {
          List<dynamic> result = json.decode(res.body);
          setState(() {
            addGames.clear();
            result.forEach((game) {
              game['wish'] = true;
              addGames.add(Game.addFromJson(game));
            });
          });
        }
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
            child: getGame(item, addButtons(item)),
            color: cardBackgroundColor,
          ));
        });
  }

  Widget addButtons(Game game) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        addButton(game, 'Xbox'),
        addButton(game, 'Playstation'),
        addButton(game, 'Switch')
      ],
    );
  }

  Widget addButton(Game game, console) {
    bool alreadyAdded = games.map((e) => e.title).toList().contains(game.title);
    if (alreadyAdded) {
      return IconButton(
        icon: getIcon(console, alreadyAdded),
        onPressed: () {},
      );
    } else {
      return IconButton(
          icon: getIcon(console, alreadyAdded),
          onPressed: () {
            setState(() {
              game.console = console;
              final body = game.toJson();
              games.add(game);
              Api.post('games', body);
            });
          });
    }
  }

  Widget getIcon(console, alreadyAdded) {
    if (console == 'Xbox') {
      return ImageIcon(
        AssetImage("assets/images/xbox_logo.png"),
        color: alreadyAdded ? addedColor : addableColor,
      );
    } else if (console == 'Playstation') {
      return ImageIcon(
        AssetImage("assets/images/ps_logo.png"),
        color: alreadyAdded ? addedColor : addableColor,
      );
    }
    return ImageIcon(
      AssetImage("assets/images/switch_logo.png"),
      color: alreadyAdded ? addedColor : addableColor,
    );
  }
}
