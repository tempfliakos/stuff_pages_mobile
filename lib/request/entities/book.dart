class Book {
  String id;
  String bookId;
  String author;
  String description;
  String picture;
  String title;

  Book(
      {this.id,
      this.bookId,
      this.author,
      this.description,
      this.picture,
      this.title});

  factory Book.fromJson(Map json) {
    return Book(
        id: json['id'],
        bookId: json['book_id'],
        author: json['author'],
        description: json['description'],
        picture: json['picture'],
        title: json['title']);
  }

  factory Book.fromJsonDelete(Map json) {
    return Book(id: json['id']);
  }

  factory Book.addFromJson(Map json) {
    return Book(
        id: json['id'],
        bookId: json['book_id'],
        author: json['author'],
        description: json['description'],
        picture: json['picture'],
        title: json['title']);
  }

  Map toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'author': author,
      'description': description,
      'picture': picture,
      'title': title
    };
  }
}
