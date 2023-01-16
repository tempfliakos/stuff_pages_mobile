
import 'package:stuff_pages/request/entities/trophyNumber.dart';

class Game {
  String? id;
  String? gameId;
  String? console;
  String? title;
  String? picture;
  int? earned;
  int? sum;
  bool? wish;
  bool? star;
  TrophyNumber? bronze;
  TrophyNumber? silver;
  TrophyNumber? gold;
  TrophyNumber? platinum;

  Game(
      {this.id,
      this.gameId,
      this.console,
      this.title,
      this.picture,
      this.earned,
      this.sum,
      this.wish,
      this.star});

  Game.highlight({
    this.id,
    this.gameId,
    this.console,
    this.title,
    this.picture,
    this.wish,
    this.star
  });

  Game.playstation({
    this.id,
    this.gameId,
    this.console,
    this.title,
    this.picture,
    this.earned,
    this.sum,
    this.wish,
    this.star,
    this.bronze,
    this.silver,
    this.gold,
    this.platinum,
  });

  factory Game.fromJson(Map json) {
    return Game(
        id: json['id'],
        gameId: json['game_id'],
        console: json['console'],
        title: json['title'],
        picture: json['picture'],
        earned: json['earned'],
        sum: json['sum'],
        wish: json['wish'],
        star: json['star']);
  }

  factory Game.starFromJson(Map json) {
    return Game.highlight(
        id: json['id'],
        gameId: json['game_id'],
        console: json['console'],
        title: json['title'],
        picture: json['picture'],
        wish: false,
        star: json['star']);
  }

  factory Game.playstationFromJson(Map json) {
    return Game.playstation(
        id: json['id'],
        gameId: json['game_id'],
        console: json['console'],
        title: json['title'],
        picture: json['picture'],
        earned: json['earned'],
        sum: json['sum'],
        wish: json['wish'],
        star: json['star'],
        bronze: TrophyNumber.fromJson(json['bronze']),
        silver: TrophyNumber.fromJson(json['silver']),
        gold: TrophyNumber.fromJson(json['gold']),
        platinum: TrophyNumber.fromJson(json['platinum']));
  }

  factory Game.addFromJson(Map json) {
    return Game(
      gameId: json['game_id'].toString(),
      console: json['console'],
      title: json['title'],
      picture: json['picture'],
      earned: json['earned'],
      sum: json['sum'],
      wish: json['wish'],
      star: json['star'],
    );
  }

  factory Game.addScreen(Map json) {
    return Game(gameId: json['game_id']);
  }

  Map toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'console': console,
      'title': title,
      'picture': picture,
      'wish': wish,
      'star': star
    };
  }
}
