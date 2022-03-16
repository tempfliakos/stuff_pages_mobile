import 'dart:convert';

import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/optionsUtil.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';
import '../request/entities/movie.dart';
import '../utils/movieUtil.dart';
import 'add_movie.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  var options;

  _getMovies() {
    filterMovies.clear();
    Api.get("movies/").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _movies = list.map((e) => Movie.fromJson(e)).toList();
        _movies.sort((a, b) => a.title.compareTo(b.title));
        filterMovies.addAll(_movies);
        options = getOptions();
        seen = options['defaultSeen'];
        owned = options['defaultOwn'];
        futureMovie = options['defaultFuture'];
        liza = options['defaultLiza'];
        filter();
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
            Icons.star,
            color: liza != null && liza ? Colors.yellow : Colors.grey[400],
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Text("Liza filmek",
              style: TextStyle(
                color: liza != null && liza ? Colors.yellow : Colors.grey[400],
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
        backgroundColor: Colors.black,
        title: Text('Filmek'),
        actions: <Widget>[optionsButton(), logoutButton()],
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
        return Slidable(
            key: UniqueKey(),
            endActionPane: ActionPane(
              // A motion is a widget used to control how the pane animates.
              motion: const ScrollMotion(),

              // All actions are defined in the children parameter.
              children: [
                // A SlidableAction can have an icon and/or a label.
                ownedButton(item),
                lizaButton(item),
                deleteButton(item),
              ],
            ),
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
                Column(
                  children: getButtons(item),
                )
              ],
            ));
      },
    );
  }

  void doNothing(BuildContext context) {}

  List<Widget> getButtons(Movie movie) {
    return released(movie) ? [seenButton(movie)] : [futureRelease()];
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
            filter();
          });
        });
  }

  Widget ownedButton(movie) {
    return SlidableAction(
      backgroundColor: Colors.grey[400],
      foregroundColor: movie.owned ? Colors.red : Colors.black,
      icon: Icons.file_download,
      label: movie.owned ? 'Megszerzett' : 'Megszerzettnek jelöl',
      onPressed: (BuildContext context) {
        setState(() {
          movie.owned = !movie.owned;
          if (!movie.owned) {
            movie.seen = false;
          }
          Api.put("movies/", movie, movie.id);
          filter();
        });
      },
    );
  }

  Widget lizaButton(movie) {
    return SlidableAction(
      backgroundColor: Colors.grey[400],
      foregroundColor: movie.liza ? Colors.yellow : Colors.black,
      icon: Icons.star,
      label: movie.liza ? 'Liza film' : 'Liza filmnek jelöl',
      onPressed: (BuildContext context) {
        setState(() {
          movie.liza = !movie.liza;
          Api.put("movies/", movie, movie.id);
          filter();
        });
      },
    );
  }

  Widget deleteButton(movie) {
    return SlidableAction(
      backgroundColor: Colors.red,
      foregroundColor: Colors.grey[400],
      icon: Icons.delete,
      label: 'Törlés',
      onPressed: (BuildContext context) {
        if (!movie.seen) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(movie.title + ' törölve')));
          setState(() {
            Api.delete("movies/", movie);
            _movies.remove(movie);
            filterMovies.remove(movie);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Előbb jelöld nem megnézettnek!')));
          setState(() {});
        }
      },
    );
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
            userStorage.deleteItem('options');
            Navigator.pushReplacementNamed(context, '/');
          });
        });
  }

  Widget optionsButton() {
    return IconButton(
        icon: Icon(
          Icons.settings,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            Navigator.pushReplacementNamed(context, '/options');
          });
        });
  }
}
