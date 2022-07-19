import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';
import 'package:stuff_pages/book/books.dart';
import 'package:stuff_pages/options.dart';
import 'package:stuff_pages/playstation/pslist.dart';
import 'package:stuff_pages/switch/switchlist.dart';
import 'package:stuff_pages/todo/todos.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/wish/wishlist.dart';

import 'login.dart';
import 'movie/movies.dart';
import 'xbox/xboxlist.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProgressHud(
        isGlobalHud: true,
        maximumDismissDuration: Duration(seconds: 2),
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
            '/todo': (context) => Todos(),
          },
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: backgroundColor,
          ),
        ));
  }
}
