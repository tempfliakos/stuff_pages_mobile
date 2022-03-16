import 'dart:convert';

import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/gameUtil.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';
import 'addwishgame.dart';

class WishList extends StatefulWidget {
  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  List<Game> _games = [];

  _getWishGames() {
    Api.get("games/wishlist/xbox").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _games = list.map((e) => Game.fromJson(e)).toList();
        _games.sort((a, b) => a.title.compareTo(b.title));
      });
    });
  }

  initState() {
    super.initState();
    _getWishGames();
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
              title: Text("Wishlist"),
              actions: <Widget>[optionsButton(), logoutButton()],
              bottom: const TabBar(
                tabs: [
                  Tab(
                      icon: ImageIcon(
                    AssetImage("assets/images/xbox_logo.png"),
                  )),
                  Tab(
                      icon: ImageIcon(
                    AssetImage("assets/images/ps_logo.png"),
                  )),
                  Tab(
                      icon: ImageIcon(
                    AssetImage("assets/images/switch_logo.png"),
                  )),
                ],
              )),
          body: TabBarView(children: [
            _tabContent("Xbox"),
            _tabContent("Playstation"),
            _tabContent("Switch"),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddWishGame(_games)));
            },
            child: Icon(Icons.add, size: 40),
            backgroundColor: Colors.green,
          ),
          bottomNavigationBar: MyNavigator(5),
          backgroundColor: Colors.grey,
        ));
  }

  filterByConsole(console) {
    return _games
        .where(
            (g) => g.console.toLowerCase() == console.toString().toLowerCase())
        .toList();
  }

  Widget _tabContent(console) {
    return Center(
      child: Column(
        children: <Widget>[Expanded(child: _gameList(console))],
      ),
    );
  }

  Widget _gameList(console) {
    return ListView.builder(
      itemCount: filterByConsole(console).length,
      itemBuilder: (context, index) {
        final item = filterByConsole(console)[index];
        return getGame(item);
      },
    );
  }

  Widget getGame(game) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[img(game)],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  child: Text(game.title),
                  width: MediaQuery.of(context).size.width * 0.50)
            ],
          ),
          Column(children: [deleteButton(game)])
        ]);
  }

  Widget deleteButton(game) {
    return IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () {
          setState(() {
            Api.delete("games/wishlist/", game);
            _games.remove(game);
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
}
