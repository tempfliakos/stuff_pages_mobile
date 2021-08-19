class Game {
  String id;
  String gameId;
  String console;
  String title;
  String picture;
  int earned;
  int sum;

  Game({this.id,
    this.gameId,
    this.console,
    this.title,
    this.picture,
    this.earned,
    this.sum});

  factory Game.fromJson(Map json) {
    return Game(
        id: json['id'],
        gameId: json['game_id'],
        console: json['console'],
        title: json['title'],
        picture: json['picture'],
        earned: json['earned'],
        sum: json['sum']);
  }

  factory Game.addFromJson(Map json) {
    return Game(
        gameId: json['game_id'].toString(),
        console: json['console'],
        title: json['title'],
        picture: json['picture'],
        earned: json['earned'],
        sum: json['sum']);
  }

  Map toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'console': console,
      'title': title,
      'picture': picture
    };
  }
}
