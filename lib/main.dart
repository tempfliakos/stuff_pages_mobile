
import 'package:Stuff_Pages/book/books.dart';
import 'package:Stuff_Pages/playstation/pslist.dart';
import 'package:Stuff_Pages/switch/switchlist.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'movie/movies.dart';
import 'xbox/xboxlist.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stuff Pages Mobile',
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        '/movies': (context) => Movies(),
        '/books': (context) => Books(),
        '/xbox': (context) => XboxList(),
        '/playstation': (context) => PsList(),
        '/switch': (context) => SwitchList(),
      },
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
    );
  }
}
