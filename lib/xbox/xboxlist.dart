import 'dart:convert';

import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
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
  List _games = new List<Game>();
  List filterGames = new List<Game>();
  var titleFilter = "";

  _getXboxGames() {
    filterGames.clear();
    Api.get("games/console=Xbox").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _games = list
            .map((e) => Game.fromJson(e))
            .where((a) => a.console.toUpperCase().contains('XBOX'))
            .toList();
        _games.sort((a, b) => a.title.compareTo(b.title));
        filterGames.addAll(_games);
      });
    });
  }

  initState() {
    super.initState();
    _getXboxGames();
  }

  dispose() {
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
          print(text);
          titleFilter = text;
          filter();
        },
        cursorColor: Colors.white,
        autofocus: false,
      ),
    );
  }

  void filter() {
    filterGames.clear();
    filterGames.addAll(_games);
    filterByTitle();
    setState(() {});
  }

  filterByTitle() {
    if (titleFilter.isNotEmpty) {
      _games.forEach((game) {
        if (!game.title.toUpperCase().contains(titleFilter.toUpperCase())) {
          filterGames.remove(game);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Xbox játékok listája"),
          actions: <Widget>[logoutButton()]),
      body: Center(
        child: Column(
          children: <Widget>[filterTitleField(), Expanded(child: _gameList())],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddXboxGame()));
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: MyNavigator(),
      backgroundColor: Colors.grey,
    );
  }

  Widget _gameList() {
    return ListView.builder(
      itemCount: filterGames.length,
      itemBuilder: (context, index) {
        final item = filterGames[index];
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
              child: img(game)),
          title: Text(game.title),
          subtitle: Text(calculatePercentage(game)),
        ),
      ],
    );
  }

  calculatePercentage(game) {
    if(game.sum == 0) {
      return "0/0";
    }
    return game.earned.toString() + "/" + game.sum.toString();
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
            Navigator.pushReplacementNamed(context, '/');
          });
        });
  }
}
