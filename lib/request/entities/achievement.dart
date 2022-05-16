class Achievement {
  String id;
  String userId;
  String gameId;
  String title;
  String description;
  bool secret;
  String picture;
  String value;
  bool earned;
  bool show;

  Achievement(
      {this.id,
      this.userId,
      this.gameId,
      this.title,
      this.description,
      this.secret,
      this.show,
      this.picture,
      this.value,
      this.earned});

  factory Achievement.fromJson(Map json) {
    return Achievement(
        id: json['id'],
        userId: json['user_id'],
        gameId: json['game_id'],
        title: json['title'],
        description: json['description'],
        secret: json['secret'],
        show: !json['secret'],
        picture: json['picture'],
        value: json['value'],
        earned: json['earned']);
  }

  Map toJson() {
    return {
      'id': id,
      'user_id': userId,
      'game_id': gameId,
      'title': title,
      'description': description,
      'secret': secret,
      'picture': picture,
      'value': value,
      'earned': earned
    };
  }
}
