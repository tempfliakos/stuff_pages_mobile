import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'global.dart';

class MyNavigator extends StatefulWidget {
  int index;
  MyNavigator(int i) {
    index = i;
  }

  @override
  _MyNavigatorState createState() => _MyNavigatorState(index);
}

class _MyNavigatorState extends State<MyNavigator> {
  final pages = [
    '/movies',
    '/books',
    '/xbox',
    '/playstation',
    '/switch',
    '/wish'
  ];

  int index;

  _MyNavigatorState(int index) {
    this.index = index;
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
      ],
      currentIndex: index,
      selectedItemColor: Colors.white,
      onTap: _onItemTapped,
      backgroundColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
    );
  }
}
