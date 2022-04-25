import 'dart:convert';

import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/movieUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../request/entities/movie.dart';
import '../request/http.dart';

class AddMovie extends StatefulWidget {
  List<Movie> addMovies = [];
  List<Movie> movies = [];

  AddMovie(List<Movie> movies) {
    this.movies = movies;
  }

  @override
  _AddMovieState createState() => _AddMovieState(movies);
}

class _AddMovieState extends State<AddMovie> {
  List<Movie> addMovies = [];
  List<Movie> movies = [];

  _AddMovieState(List<Movie> movies) {
    this.movies = movies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Filmek hozzáadása"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            findMovieField(),
            Expanded(child: _movieList()),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget findMovieField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Film hozzáadása...',
      ),
      onChanged: (text) {
        findMovies(text);
      },
    );
  }

  void findMovies(text) {
    if (text.length > 2) {
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
      });
    } else {
      addMovies.clear();
    }
  }

  Widget _movieList() {
    return ListView.builder(
        itemCount: addMovies.length,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: img(addMovies[index]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      child: filmText(addMovies[index]),
                      width: MediaQuery.of(context).size.width * 0.50)
                ],
              ),
              Column(children: <Widget>[addButton(addMovies[index])])
            ],
          );
        });
  }

  Widget addButton(movie) {
    if (movies.map((e) => e.title).toList().contains(movie.title)) {
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
              movies.add(movie);
              Api.post('movies', body);
            });
          });
    }
  }
}
