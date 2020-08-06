
import 'package:Stuff_Pages/playstation/pslist.dart';
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
        '/xbox': (context) => XboxList(),
        '/playstation': (context) => PsList(),
        '/options': (context) => Movies(),
      },
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
    );
  }
}
