class Game {
  String id;
  String gameId;
  String console;
  String title;
  String picture;
  int earned;
  int sum;
  bool wish;
  bool star;

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
