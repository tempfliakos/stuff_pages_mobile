import 'package:Stuff_Pages/utils/genres.dart';

class Movie {
  String id;
  String movieId;
  String backdropPath;
  String posterPath;
  String releaseDate;
  String title;
  bool seen;
  bool owned;
  bool liza;
  List<dynamic> genres;

  Movie(
      {this.id,
      this.movieId,
      this.backdropPath,
      this.posterPath,
      this.releaseDate,
      this.title,
      this.seen,
      this.owned,
      this.liza,
      this.genres});

  factory Movie.fromJson(Map json) {
    return Movie(
        id: json['id'],
        backdropPath: json['backdrop_path'],
        posterPath: json['poster_path'],
        releaseDate: json['release_date'],
        title: json['title'],
        seen: json['seen'],
        owned: json['owned'],
        liza: json['liza'],
        genres: json["genres"]);
  }

  factory Movie.fromJsonDelete(Map json) {
    return Movie(id: json['id']);
  }

  factory Movie.addFromJson(Map json) {
    getGenres() {
      List<dynamic> genres = [];
      json["genre_ids"].forEach((e) => {
            defaultGenres.forEach((element) {
              if (element["key"] == e) {
                genres.add(element["text"]);
              }
            })
          });
      return genres;
    }

    return Movie(
        id: json['id'].toString(),
        backdropPath: json['backdrop_path'],
        posterPath: json['poster_path'],
        releaseDate: json['release_date'],
        title: json['title'],
        seen: false,
        owned: false,
        liza: false,
        genres: getGenres());
  }

  factory Movie.addScreen(Map json) {
    return Movie(movieId: json['movie_id']);
  }

  Map toJson() {
    return {
      'id': id,
      'backdrop_path': backdropPath,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'title': title,
      'seen': seen,
      'owned': owned,
      'liza': liza,
      'genres': genres
    };
  }
}
