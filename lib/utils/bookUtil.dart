import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget bookText(book) {
  return Text(
    book.title,
    textAlign: TextAlign.start,
    overflow: TextOverflow.ellipsis,
    textWidthBasis: TextWidthBasis.parent,
    maxLines: 10,
    style: TextStyle(
      fontSize: 16,
    ),
  );
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
