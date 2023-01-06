import 'package:flutter/material.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/utils/colorUtil.dart';

class CustomNavigator extends StatefulWidget {
  late MenuEnum menuEnum;
  CustomNavigator(MenuEnum menuEnum) {
    this.menuEnum = menuEnum;
  }

  @override
  _CustomNavigatorState createState() => _CustomNavigatorState(menuEnum);
}

class _CustomNavigatorState extends State<CustomNavigator> {
  final pages = [
    MenuEnum.MOVIES.getAsPath(),
    MenuEnum.BOOKS.getAsPath(),
    MenuEnum.XBOX_GAMES.getAsPath(),
    MenuEnum.PS_GAMES.getAsPath(),
    MenuEnum.SWITCH_GAMES.getAsPath(),
    MenuEnum.WISHLIST.getAsPath(),
    MenuEnum.TODOS.getAsPath()
  ];

  late MenuEnum menuEnum;
  //int index = 0;

  _CustomNavigatorState(MenuEnum menuEnum) {
    this.menuEnum = menuEnum;
    //this.index = index;
  }

  void _onItemTapped(int index) {
    setState(() {
      Navigator.pushReplacementNamed(context, pages[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.movie_outlined),
          label: 'Filmek',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Könyvek',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("assets/images/xbox_logo.png"),
          ),
          label: 'Xbox',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("assets/images/ps_logo.png"),
          ),
          label: 'Playstation',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("assets/images/switch_logo.png"),
          ),
          label: 'Switch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videogame_asset_outlined),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          label: 'Feladatok',
        ),
      ],
      currentIndex: menuEnum.index,
      selectedItemColor: futureColor,
      onTap: _onItemTapped,
      backgroundColor: backgroundColor,
      type: BottomNavigationBarType.fixed,
    );
  }
}
