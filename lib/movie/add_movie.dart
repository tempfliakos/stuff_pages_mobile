import 'dart:convert';

import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';
import 'package:stuff_pages/global.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/movieUtil.dart';

import '../request/entities/movie.dart';
import '../request/http.dart';

class AddMovie extends StatefulWidget {
  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  List<Movie> addMovies = [];
  List<Movie> movies = [];

  _AddMovieState() {
    Api.get("movies/ids").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        movies = list.map((e) => Movie.addScreen(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: searchBar("Film hozzáadása...", findMovies),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _movieList()),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  void findMovies(text) {
    if (text.length > 2) {
      ProgressHud.showLoading();
      Api.getFromApi("movies", text.toString()).then((res) {
        if (res != null) {
          List<dynamic> result = json.decode(res.body);
          setState(() {
            addMovies.clear();
            result.forEach((movie) {
              addMovies.add(Movie.addFromJson(movie));
            });
          });
        }
        ProgressHud.dismiss();
      });
    } else {
      addMovies.clear();
    }
  }

  Widget _movieList() {
    return ListView.builder(
        itemCount: addMovies.length,
        itemBuilder: (context, index) {
          final item = addMovies[index];
          return InkWell(
              child: Card(
            child: getMovie(item, addButton(item)),
            color: cardBackgroundColor,
          ));
        });
  }

  Widget addButton(movie) {
    if (movies.map((e) => e.movieId).toList().contains(movie.id)) {
      return IconButton(
        icon: Icon(
          Icons.check_circle,
          color: addedColor,
        ),
        onPressed: () {},
      );
    } else {
      return IconButton(
          icon: Icon(
            Icons.check_circle_outline,
            color: addableColor,
          ),
          onPressed: () {
            setState(() {
              final body = movie.toJson();
              movies.add(Movie(movieId: body['id']));
              Api.post('movies', body);
            });
          });
    }
  }
}
