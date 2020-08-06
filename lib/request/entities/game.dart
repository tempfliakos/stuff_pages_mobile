class Game {
  String id;
  String userId;
  String gameId;
  String console;
  String title;
  String picture;
  int earned;
  int sum;

  Game(
      {this.id,
        this.userId,
        this.gameId,
        this.console,
        this.title,
        this.picture,
        this.earned,
        this.sum});

  factory Game.fromJson(Map json) {
    return Game(
        id: json['id'],
        userId: json['user_id'],
        gameId: json['game_id'],
        console: json['console'],
        title: json['title'],
        picture: json['picture'],
        earned: json['earned'],
        sum: json['sum']);
  }

  Map toJson() {
    return {
      'id': id,
      'user_id': userId,
      'game_id': gameId,
      'console': console,
      'title': title,
      'picture': picture
    };
  }
}
