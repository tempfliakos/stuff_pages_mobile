import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget filmText(movie) {
  return Text(
    movie.title,
    textAlign: TextAlign.start,
    overflow: TextOverflow.ellipsis,
    textWidthBasis: TextWidthBasis.parent,
    maxLines: 10,
    style: TextStyle(
      fontSize: 16,
    ),
  );
}

Widget img(movie) {
  if (movie.backdropPath != null && movie.backdropPath != "null") {
    return Image.network(
      'https://image.tmdb.org/t/p/w500/' + movie.backdropPath,
      scale: 4,
      filterQuality: FilterQuality.high,
    );
  } else {
    return Image.asset('assets/images/default-movie-back.jpg', scale: 2.32);
  }
}
