import 'package:flutter/material.dart';
import 'package:stuff_pages/utils/colorUtil.dart';

import '../request/entities/movie.dart';

Widget getMovie(Movie movie, Widget trailing) {
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
            child: img(movie)),
        title: Text(movie.title, style: TextStyle(color: fontColor)),
        subtitle: getGenres(movie),
        trailing: trailing,
      ),
    ],
  );
}

Text getGenres(Movie movie) {
  if(movie != null && movie.genres.isNotEmpty) {
    String result = "";
    String separator = "";
    for(var genre in movie.genres) {
      result += separator;
      result += genre;
      separator = ", ";
    }
    return Text(result, style: TextStyle(color: fontColor));
  }
  return null;
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
