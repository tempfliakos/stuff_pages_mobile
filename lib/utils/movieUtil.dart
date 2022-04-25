import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../request/entities/movie.dart';

Widget filmText(movie) {
  return Text(
    movie.title,
    textAlign: TextAlign.start,
    overflow: TextOverflow.ellipsis,
    textWidthBasis: TextWidthBasis.parent,
    maxLines: 10,
    style: TextStyle(
      color: fontColor,
      fontSize: 16,
    ),
  );
}

Widget img(Movie movie) {
  if (movie.backdropPath != null && movie.backdropPath != "null") {
    return ClipRRect(
      child: Image.network(
        'https://image.tmdb.org/t/p/w500/' + movie.backdropPath,
        scale: 4,
        filterQuality: FilterQuality.high,
      ),
      borderRadius: BorderRadius.circular(0.0),
    );
  } else {
    return ClipRRect(
      child: Image.asset('assets/images/default-movie-back.jpg', scale: 2.32),
      borderRadius: BorderRadius.circular(0.0),
    );
  }
}
