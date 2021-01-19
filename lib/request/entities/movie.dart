import 'package:Stuff_Pages/utils/genres.dart';

class Movie {
  String id;
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
      List<dynamic> genres = new List<dynamic>();
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
