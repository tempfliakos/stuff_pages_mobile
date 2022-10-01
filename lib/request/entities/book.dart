class Book {
  String id;
  String bookId;
  String author;
  String description;
  String picture;
  String title;
  String priority;

  Book(
      {this.id,
      this.bookId,
      this.author,
      this.description,
      this.picture,
      this.title,
      this.priority});

  factory Book.fromJson(Map json) {
    return Book(
        id: json['id'],
        bookId: json['book_id'],
        author: json['author'],
        description: json['description'],
        picture: json['picture'],
        title: json['title'],
        priority: json['priority']);
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
        title: json['title'],
        priority: json['priority']);
  }

  factory Book.addScreen(Map json) {
    return Book(bookId: json['book_id']);
  }

  Map toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'author': author,
      'description': description,
      'picture': picture,
      'title': title,
      'priority': priority
    };
  }
}
