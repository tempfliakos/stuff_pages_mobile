import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'global.dart';

class MyNavigator extends StatefulWidget {
  @override
  _MyNavigatorState createState() => _MyNavigatorState();
}

class _MyNavigatorState extends State<MyNavigator> {
  final pages = ['/movies','/xbox', '/playstation', '/options'];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      Navigator.pushReplacementNamed(context, pages[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.movie),
          title: Text('Filmek'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videogame_asset),
          title: Text('Xbox'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videogame_asset),
          title: Text('Playstation'),
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.white,
      onTap: _onItemTapped,
      backgroundColor: Colors.grey[600],
    );
  }
}
