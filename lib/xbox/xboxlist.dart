import 'dart:convert';

import 'package:stuff_pages/constants/achievementConstants.dart';
import 'package:stuff_pages/enums/gamesEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/gameUtil.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';
import '../achievement/achievementlist.dart';
import 'addxboxgame.dart';

class XboxList extends StatefulWidget {
  @override
  _XboxListState createState() => _XboxListState();
}

class _XboxListState extends State<XboxList> {
  late ScrollController controller;
  List<Game> _games = [];
  List<Game> _starred = [];
  String titleFilter = "";
  int pageNumber = 1;
  late int maxPageNumber;
  bool filterMode = false;

  _getXboxGames() {
    Api.get("games/console=Xbox&page=$pageNumber&title=$titleFilter")
        .then((res) {
      setState(() {
        try {
          Map<String, dynamic> data = json.decode(res.body);
          Iterable list = data[GamesEnum.games.name];
          maxPageNumber = (data[GamesEnum.count.name] / list.length).ceil();
          List<Game> games = list.map((e) => Game.fromJson(e)).toList();
          List<String?> _gamesIds = games.map((e) => e.gameId).toList();
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
    Api.get("games/star/console=Xbox").then((res) {
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

  @override
  initState() {
    super.initState();
    _getXboxGames();
    _getStarGames();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
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
    _getXboxGames();
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
      body: Scrollbar(
        child: Center(
          child: Column(
            children: <Widget>[getStarList(), Expanded(child: _gameList())],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddXboxGame()));
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: addedColor,
      ),
      bottomNavigationBar: CustomNavigator(MenuEnum.XBOX_GAMES),
      backgroundColor: backgroundColor,
    );
  }

  Widget titleWidget() {
    if (!filterMode) {
      return Text('Xbox játékok listája', style: TextStyle(color: fontColor));
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
            child: getGame(item, starButton(item)),
            color: cardBackgroundColor,
          ),
          onTap: () => openAchievements(item),
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
        onTap: () => openAchievements(starred),
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
    if(game.star! || game.sum != game.earned) {
      return IconButton(
          icon: Icon(
            game.star! ? Icons.star : Icons.star_border,
            color: futureColor,
          ),
          onPressed: () {
            setState(() {
              game.star = !game.star!;
              Api.put("games/", game, game.id);
              if (game.star!) {
                _starred.add(game);
              } else {
                _starred.removeWhere((g) => g.id == game.id);
              }
            });
          });
    } else {
      return IconButton(
          icon: Icon(
            Icons.done_all,
            color: addedColor,
          ),
          onPressed: () {});
    }
  }

  void _scrollListener() {
    if (maxPageNumber >= pageNumber && controller.position.extentAfter == 0) {
      ProgressHud.showLoading();
      pageNumber++;
      _getXboxGames();
    }
  }

  void openAchievements(Game game) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ShowAchievement(game, xboxSecretTitle, xboxSecretDescription)));
    _getXboxGames();
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
      Navigator.pushReplacementNamed(context, MenuEnum.OPTIONS.getAsPath());
    });
  }
}
