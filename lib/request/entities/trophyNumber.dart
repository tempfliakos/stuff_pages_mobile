class TrophyNumber {
  int? earned;
  int? sum;

  TrophyNumber({this.earned, this.sum});

  factory TrophyNumber.fromJson(Map json) {
    return TrophyNumber(earned: json['earned'], sum: json['sum']);
  }
}
