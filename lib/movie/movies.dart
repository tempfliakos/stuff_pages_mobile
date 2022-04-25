import 'dart:convert';
import 'dart:math';

import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
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
  List<Movie> _movies = [];
  List<Movie> filterMovies = [];
  String titleFilter = "";
  var seen;
  var owned;
  var futureMovie;
  var liza;
  Map<String, Object> options;
  bool filterMode = false;

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

  void titleField(String text) {
    titleFilter = text;
    filter();
  }

  Widget filterNotSeen() {
    return TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.remove_red_eye,
              color: seen != null && seen ? addedColor : fontColor,
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text("Megnézett filmek",
                style: TextStyle(
                    color: seen != null && seen ? addedColor : fontColor))
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
              color: owned != null && owned ? deleteColor : fontColor,
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text("Beszerzett filmek",
                style: TextStyle(
                    color: owned != null && owned ? deleteColor : fontColor))
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
            color: futureMovie != null && futureMovie ? futureColor : fontColor,
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Text("Jövőbeni filmek",
              style: TextStyle(
                  color: futureMovie != null && futureMovie
                      ? futureColor
                      : fontColor))
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
            color: liza != null && liza ? futureColor : fontColor,
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Text("Liza filmek",
              style: TextStyle(
                color: liza != null && liza ? futureColor : fontColor,
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
            color: fontColor,
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Text("Szűrők alaphalyzetbe", style: TextStyle(color: fontColor))
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

  void doFilter() {
    _movies.forEach((movie) {
      if (movie.title.toLowerCase().contains(titleFilter.toLowerCase())) {
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
        backgroundColor: backgroundColor,
        title: titleWidget(),
        actions: <Widget>[
          filterButton(doFilterChange),
          optionsButton(doOptions),
          logoutButton(doLogout)
        ],
        iconTheme: IconThemeData(color: fontColor),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _movieList()),
          ],
        ),
      ),
      drawer: Theme(
          data: Theme.of(context).copyWith(canvasColor: cardBackgroundColor),
          child: Drawer(
            backgroundColor: cardBackgroundColor,
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
        backgroundColor: addedColor,
      ),
      bottomNavigationBar: MyNavigator(0),
      backgroundColor: backgroundColor,
    );
  }

  Widget titleWidget() {
    if (!filterMode) {
      return Text('Filmek', style: TextStyle(color: fontColor));
    } else {
      return searchBar("Film címe", titleField);
    }
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
            child: InkWell(
              child: Card(
                child: getMovie(item, seenButton(item)),
                color: cardBackgroundColor,
              ),
            ));
      },
    );
  }

  List<Widget> getButtons(Movie movie) {
    return released(movie) ? [seenButton(movie)] : [futureRelease()];
  }

  Widget seenButton(movie) {
    return IconButton(
        icon: Icon(
          Icons.remove_red_eye,
          color: movie.seen ? addedColor : addableColor,
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
      backgroundColor: addableColor,
      foregroundColor: movie.owned ? deleteColor : whiteColor,
      icon: Icons.file_download,
      label: movie.owned ? 'Megszerzett' : 'Nem megszerzett',
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
      backgroundColor: addableColor,
      foregroundColor: movie.liza ? futureColor : whiteColor,
      icon: Icons.star,
      label: movie.liza ? 'Liza film' : 'Nem Liza film',
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
      backgroundColor: deleteColor,
      foregroundColor: whiteColor,
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
        color: futureColor,
      ),
      onPressed: () {},
    );
  }

  bool released(movie) {
    DateTime date = DateTime.parse(movie.releaseDate);
    return date.isBefore(DateTime.now());
  }

  void doFilterChange() {
    setState(() {
      filterMode = !filterMode;
    });
  }

  void doLogout() {
    setState(() {
      resetStorage();
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void doOptions() {
    setState(() {
      Navigator.pushReplacementNamed(context, '/options');
    });
  }
}
