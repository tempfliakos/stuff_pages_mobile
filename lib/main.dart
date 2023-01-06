import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';
import 'package:stuff_pages/book/books.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
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
            MenuEnum.MOVIES.getAsPath(): (context) => Movies(),
            MenuEnum.BOOKS.getAsPath(): (context) => Books(),
            MenuEnum.XBOX_GAMES.getAsPath(): (context) => XboxList(),
            MenuEnum.PS_GAMES.getAsPath(): (context) => PsList(),
            MenuEnum.SWITCH_GAMES.getAsPath(): (context) => SwitchList(),
            MenuEnum.WISHLIST.getAsPath(): (context) => WishList(),
            MenuEnum.TODOS.getAsPath(): (context) => Todos(),
            MenuEnum.OPTIONS.getAsPath(): (context) => Options(),
          },
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: backgroundColor,
          ),
        ));
  }
}
