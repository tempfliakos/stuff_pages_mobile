import 'package:Stuff_Pages/book/books.dart';
import 'package:Stuff_Pages/options.dart';
import 'package:Stuff_Pages/playstation/pslist.dart';
import 'package:Stuff_Pages/switch/switchlist.dart';
import 'package:Stuff_Pages/wish/wishlist.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'movie/movies.dart';
import 'xbox/xboxlist.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProgressHud(
        isGlobalHud: true,
        child: MaterialApp(
          title: 'Stuff Pages Mobile',
          initialRoute: '/',
          routes: {
            '/': (context) => Login(),
            '/options': (context) => Options(),
            '/movies': (context) => Movies(),
            '/books': (context) => Books(),
            '/xbox': (context) => XboxList(),
            '/playstation': (context) => PsList(),
            '/switch': (context) => SwitchList(),
            '/wish': (context) => WishList(),
          },
          theme: ThemeData(
            primaryColor: Colors.black,
          ),
        ));
  }
}
