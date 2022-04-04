import 'dart:convert';

import 'package:Stuff_Pages/playstation/addpsgame.dart';
import 'package:Stuff_Pages/playstation/trophylist.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';

class PsList extends StatefulWidget {
  @override
  _PsListState createState() => _PsListState();
}

class _PsListState extends State<PsList> {
  ScrollController controller;
  List<Game> _games = [];
  String titleFilter = "";
  int pageNumber = 1;

  _getPsGames() {
    Api.get("games/console=Playstation&page=$pageNumber&title=$titleFilter")
        .then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        List<Game> games = list.map((e) => Game.fromJson(e)).toList();
        _games.addAll(createFinalGameList(games));
        ProgressHud.dismiss();
      });
    });
  }

  initState() {
    super.initState();
    _getPsGames();
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
    _getPsGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Text("Playstation játékok listája"),
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
              MaterialPageRoute(builder: (context) => AddPsGame(_games)));
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: MyNavigator(3),
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
                MaterialPageRoute(builder: (context) => ShowTrophy(item)));
            _getPsGames();
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
              child: img(game)),
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
    if (controller.position.extentAfter == 0) {
      ProgressHud.showLoading();
      pageNumber++;
      _getPsGames();
    }
  }
}
