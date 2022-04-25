import 'dart:convert';

import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:flutter/material.dart';

class AddSwitchGame extends StatefulWidget {
  List<Game> addGames = [];
  List<Game> games = [];

  AddSwitchGame(List<Game> games) {
    this.games = games;
  }

  @override
  _AddSwitchGameState createState() => _AddSwitchGameState(games);
}

class _AddSwitchGameState extends State<AddSwitchGame> {
  List<Game> addGames = [];
  List<Game> games = [];
  String queryString = "";

  _AddSwitchGameState(List<Game> games) {
    this.games = games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Játékok hozzáadása"),
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
      Api.getFromApi("switch", queryString.toString()).then((res) {
        if (res != null) {
          List<dynamic> result = json.decode(res.body);
          setState(() {
            addGames.clear();
            result.forEach((game) {
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
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: img(addGames[index]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      child: addGameText(addGames[index]),
                      width: MediaQuery.of(context).size.width * 0.50)
                ],
              ),
              Column(children: <Widget>[addButton(addGames[index])])
            ],
          );
        });
  }

  Widget addButton(game) {
    if (games.map((e) => e.title).toList().contains(game.title)) {
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
