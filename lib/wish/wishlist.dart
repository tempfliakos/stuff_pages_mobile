import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/gameUtil.dart';

import '../global.dart';
import '../navigator.dart';
import 'addwishgame.dart';

class WishList extends StatefulWidget {
  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  List<Game> _games = [];
  static const String XBOX = "Xbox";
  static const String PS = "Playstation";
  static const String SWITCH = "Switch";

  _getWishGames() {
    Api.get("games/wishlist").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _games = list.map((e) => Game.fromJson(e)).toList();
        _games.sort((a, b) => removeDiacritics(a.title!).compareTo(removeDiacritics(b.title!)));
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
              title: Text("Wishlist", style: TextStyle(color: fontColor)),
              actions: <Widget>[optionsButton(doOptions), logoutButton(doLogout)],
              bottom: TabBar(
                indicatorColor: futureColor,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(filterByConsole(XBOX).length.toString(), style: TextStyle(color: fontColor, fontSize: 20)),
                        const SizedBox(width: 8),
                        ImageIcon(AssetImage("assets/images/xbox_logo.png"),)
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(filterByConsole(PS).length.toString(), style: TextStyle(color: fontColor, fontSize: 20)),
                        const SizedBox(width: 8),
                        ImageIcon(AssetImage("assets/images/ps_logo.png"),)
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(filterByConsole(SWITCH).length.toString(), style: TextStyle(color: fontColor, fontSize: 20)),
                        const SizedBox(width: 8),
                        ImageIcon(AssetImage("assets/images/switch_logo.png"),)
                      ],
                    ),
                  ),
                ],
              )),
          body: TabBarView(children: [
            _tabContent(XBOX),
            _tabContent(PS),
            _tabContent(SWITCH),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddWishGame()));
            },
            child: Icon(Icons.add, size: 40),
            backgroundColor: addedColor,
          ),
          bottomNavigationBar: CustomNavigator(MenuEnum.WISHLIST),
          backgroundColor: backgroundColor,
        ));
  }

  filterByConsole(console) {
    return _games
        .where(
            (g) => g.console!.toLowerCase() == console.toString().toLowerCase())
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
            child: getGame(context, item, deleteButton(item)),
            color: cardBackgroundColor,
          )
        );
      },
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
