import 'dart:convert';

import 'package:Stuff_Pages/request/http.dart';
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
  List _movies = [];
  List filterMovies = [];
  var titleFilter = "";
  var seen;
  var owned;
  var futureMovie;
  var liza;

  _getMovies() {
    filterMovies.clear();
    Api.get("movies/").then((res) {
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

  Widget filterNotSeen() {
    return TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.remove_red_eye,
              color: seen != null && seen ? Colors.blue : Colors.grey[400],
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text("Megnézett filmek",
                style: TextStyle(
                    color:
                        seen != null && seen ? Colors.blue : Colors.grey[400]))
          ],
        ),
        onPressed: () {
          seen = seen != null ? !seen : true;
          filter();
        });
  }

  Widget filterNotOwned() {
    return TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.file_download,
              color: owned != null && owned ? Colors.red : Colors.grey[400],
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text("Beszerzett filmek",
                style: TextStyle(
                    color:
                        owned != null && owned ? Colors.red : Colors.grey[400]))
          ],
        ),
        onPressed: () {
          owned = owned != null ? !owned : true;
          filter();
        });
  }

  Widget filterForFutureMovies() {
    return TextButton(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.access_time,
            color: futureMovie != null && futureMovie
                ? Colors.yellow
                : Colors.grey[400],
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Text("Jövőbeni filmek",
              style: TextStyle(
                  color: futureMovie != null && futureMovie
                      ? Colors.yellow
                      : Colors.grey[400]))
        ],
      ),
      onPressed: () {
        futureMovie = futureMovie != null ? !futureMovie : true;
        filter();
      },
    );
  }

  Widget filterForLizaMovies() {
    return TextButton(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.spa,
            color: liza != null && liza ? Colors.green[900] : Colors.grey[400],
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Text("Liza filmek",
              style: TextStyle(
                color:
                    liza != null && liza ? Colors.green[900] : Colors.grey[400],
              ))
        ],
      ),
      onPressed: () {
        liza = liza != null ? !liza : true;
        filter();
      },
    );
  }

  Widget resetFilter() {
    return TextButton(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.repeat,
            color: Colors.grey[400],
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Text("Szűrők alaphalyzetbe",
              style: TextStyle(color: Colors.grey[400]))
        ],
      ),
      onPressed: () {
        seen = null;
        owned = null;
        futureMovie = null;
        liza = null;
        filter();
      },
    );
  }

  void filter() {
    filterMovies.clear();
    doFilter();
    setState(() {});
  }

  doFilter() {
    _movies.forEach((movie) {
      if (movie.title.toUpperCase().startsWith(titleFilter.toUpperCase())) {
        if (seen != null ||
            owned != null ||
            futureMovie != null ||
            liza != null) {
          if ((seen == null || movie.seen == seen) &&
              (owned == null || movie.owned == owned) &&
              (futureMovie == null || released(movie) == !futureMovie) &&
              (liza == null || movie.liza == liza)) {
            filterMovies.add(movie);
          }
        } else {
          filterMovies.add(movie);
        }
      }
    });
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
      drawer: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.grey[600]),
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                resetFilter(),
                filterNotSeen(),
                filterNotOwned(),
                filterForFutureMovies(),
                filterForLizaMovies(),
              ],
            ),
          )),
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
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(item.title + ' törölve')));
                setState(() {
                  Api.delete("movies/", item);
                  _movies.remove(item);
                  filterMovies.remove(item);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
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
                Row(
                  children: getButtons(item),
                )
              ],
            ));
      },
    );
  }

  List<Widget> getButtons(Movie movie) {
    if (released(movie)) {
      return [
        seenButton(movie),
        ownedButton(movie),
        lizaButton(movie)
      ];
    }
    return [futureRelease()];
  }

  Widget seenButton(movie) {
    return IconButton(
        icon: Icon(
          Icons.remove_red_eye,
          color: movie.seen ? Colors.blue : Colors.grey[400],
        ),
        onPressed: () {
          setState(() {
            if (movie.owned) {
              movie.seen = !movie.seen;
              Api.put("movies/", movie, movie.id);
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
            Api.put("movies/", movie, movie.id);
          });
        });
  }

  Widget lizaButton(movie) {
    return IconButton(
        icon: Icon(
          Icons.spa,
          color: movie.liza ? Colors.green[800] : Colors.grey[400],
        ),
        onPressed: () {
          setState(() {
            movie.liza = !movie.liza;
            Api.put("movies/", movie, movie.id);
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
