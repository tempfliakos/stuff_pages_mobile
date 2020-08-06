import 'dart:convert';

import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/genres.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';
import '../request/entities/movie.dart';
import '../utils/movieUtil.dart';
import 'add_movie.dart';

class Movies extends StatefulWidget {
  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  List _movies = new List<Movie>();
  List filterMovies = new List<Movie>();
  var titleFilter = "";
  var genreFilter = "";

  _getMovies() {
    filterMovies.clear();
    final user = 'user=' + userStorage.getItem('user');
    Api.get("movies/", user).then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _movies = list.map((e) => Movie.fromJson(e)).toList();
        _movies.sort((a, b) => a.title.compareTo(b.title));
        filterMovies.addAll(_movies);
      });
    });
  }

  initState() {
    super.initState();
    _getMovies();
  }

  dispose() {
    super.dispose();
  }

  Widget filterTitleField() {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.black),
      child: TextField(
        decoration: InputDecoration(
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            labelText: 'Film címe...'),
        onChanged: (text) {
          titleFilter = text;
          filter();
        },
        cursorColor: Colors.white,
        autofocus: false,
      ),
    );
  }

  Widget filterGenreField() {
    return Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.black),
        child: DropdownButton(
          value: genreFilter,
          items: defaultGenres.map<DropdownMenuItem>((value) {
            print(value);
            return DropdownMenuItem(
              value: value['key'],
              child: Text(value['text']),
            );
          }).toList(),
          onChanged: (value) {},
        ));
  }

  void filter() {
    filterMovies.clear();
    filterMovies.addAll(_movies);
    filterByTitle();
    filterByGenre();
    setState(() {});
  }

  filterByTitle() {
    if (titleFilter.isNotEmpty) {
      _movies.forEach((movie) {
        if (!movie.title.toUpperCase().startsWith(titleFilter.toUpperCase())) {
          filterMovies.remove(movie);
        }
      });
    }
  }

  filterByGenre() {
    if (genreFilter.isNotEmpty) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filmek'),
        actions: <Widget>[logoutButton()],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            filterTitleField(),
            Expanded(child: _movieList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddMovie(_movies)));
          _getMovies();
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: MyNavigator(),
      backgroundColor: Colors.grey,
    );
  }

  Widget _movieList() {
    return ListView.builder(
      itemCount: filterMovies.length,
      itemBuilder: (context, index) {
        final item = filterMovies[index];
        return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              if (!item.seen) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(item.title + ' törölve')));
                setState(() {
                  Api.delete("movies/", item);
                  _movies.remove(item);
                  filterMovies.remove(item);
                });
              } else {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Előbb jelöld nem megnézettnek!')));
                setState(() {});
              }
            },
            background: Container(color: Colors.red),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[img(item)],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        child: filmText(item),
                        width: MediaQuery.of(context).size.width * 0.50)
                  ],
                ),
                released(item)
                    ? Column(
                        children: <Widget>[seenButton(item), ownedButton(item)])
                    : Column(children: <Widget>[futureRelease()]),
              ],
            ));
      },
    );
  }

  Widget seenButton(movie) {
    return IconButton(
        icon: Icon(
          Icons.remove_red_eye,
          color: movie.seen ? Colors.green : Colors.grey[400],
        ),
        onPressed: () {
          setState(() {
            if (movie.owned) {
              movie.seen = !movie.seen;
              Api.put("movies/", movie, movie.movieId);
            }
          });
        });
  }

  Widget ownedButton(movie) {
    return IconButton(
        icon: Icon(
          Icons.file_download,
          color: movie.owned ? Colors.red : Colors.grey[400],
        ),
        onPressed: () {
          setState(() {
            movie.owned = !movie.owned;
            if (!movie.owned) {
              movie.seen = false;
            }
            Api.put("movies/", movie, movie.movieId);
          });
        });
  }

  Widget futureRelease() {
    return IconButton(
      icon: Icon(
        Icons.access_time,
        color: Colors.yellow,
      ),
      onPressed: () {},
    );
  }

  bool released(movie) {
    DateTime date = DateTime.parse(movie.releaseDate);
    return date.isBefore(DateTime.now());
  }

  Widget logoutButton() {
    return IconButton(
        icon: Icon(
          Icons.power_settings_new,
          color: Colors.red,
        ),
        onPressed: () {
          setState(() {
            userStorage.deleteItem('user');
            Navigator.pushReplacementNamed(context, '/');
          });
        });
  }
}

