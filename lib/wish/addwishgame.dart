import 'dart:convert';

import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/gameUtil.dart';

import '../global.dart';

class AddWishGame extends StatefulWidget {
  @override
  _AddWishGameState createState() => _AddWishGameState();
}

class _AddWishGameState extends State<AddWishGame> {
  List<Game> addGames = [];
  List<Game> games = [];
  String queryString = "";

  _AddWishGameState() {
    Api.get("games/wishlist/ids").then((res) {
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
        actions: [searchIcon()],
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
            child: getGame(context, item, addButtons(item)),
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
    bool alreadyAdded =
        games.map((e) => e.gameId).toList().contains(game.gameId);
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
