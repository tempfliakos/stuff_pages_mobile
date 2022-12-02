enum SearchEnum {
  youtube("https://www.youtube.com/results?search_query="),
  google("https://www.google.com/search?q=");

  const SearchEnum(this.url);
  final String url;
}
