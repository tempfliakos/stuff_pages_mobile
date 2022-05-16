import 'package:flutter/material.dart';

import '../request/entities/book.dart';
import 'colorUtil.dart';

Widget getBook(Book book, Widget trailing) {
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
            child: img(book)),
        title: Text(cutString(book.title, 30), style: TextStyle(color: fontColor)),
        subtitle: Text(cutString(book.author, 33), style: TextStyle(color: fontColor)),
        trailing: trailing,
      ),
    ],
  );
}

String cutString(String s, length) {
  if(s.length > length) {
    return s.substring(0,length-4) + "...";
  }
  return s;
}

Widget img(book) {
  if (book.picture != null && book.picture != "null") {
    return Image.network(
      book.picture,
      scale: 4,
      filterQuality: FilterQuality.high,
    );
  } else {
    return Image.asset('assets/images/default-movie-back.jpg', scale: 2.32);
  }
}
