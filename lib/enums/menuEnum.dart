enum MenuEnum {
  MOVIES,
  BOOKS,
  XBOX_GAMES,
  PS_GAMES,
  SWITCH_GAMES,
  WISHLIST,
  TODOS,
  OPTIONS;

  String getAsPath() {
    return "/" + this.name;
  }
}
