import 'dart:convert';

import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
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
              backgroundColor: backgroundColor,
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
            backgroundColor: addedColor,
          ),
          bottomNavigationBar: MyNavigator(5),
          backgroundColor: backgroundColor,
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
        return InkWell(
          child: Card(
            child: getGame(item),
            color: cardBackgroundColor,
          )
        );
      },
    );
  }

  Widget getGame(Game game) {
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
          trailing: deleteButton(game),
        ),
      ],
    );
  }

  Widget deleteButton(game) {
    return IconButton(
        icon: Icon(
          Icons.delete,
          color: deleteColor,
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
}
