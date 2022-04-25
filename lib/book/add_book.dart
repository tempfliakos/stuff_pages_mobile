import 'dart:convert';

import 'package:Stuff_Pages/request/entities/book.dart';
import 'package:Stuff_Pages/utils/bookUtil.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:flutter/material.dart';

import '../request/http.dart';

class AddBook extends StatefulWidget {
  List<Book> addBooks = [];
  List<Book> books = [];

  AddBook(List<Book> books) {
    this.books = books;
  }

  @override
  _AddBookState createState() => _AddBookState(books);
}

class _AddBookState extends State<AddBook> {
  List<Book> addBooks = [];
  List<Book> books = [];

  _AddBookState(List<Book> books) {
    this.books = books;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Könyvek hozzáadása"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            findBookField(),
            Expanded(child: _bookList()),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget findBookField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Könyv hozzáadása...',
      ),
      onChanged: (text) {
        findBooks(text);
      },
    );
  }

  void findBooks(text) {
    if (text.length > 2) {
      Api.getFromApi("books", text.toString()).then((res) {
        if (res != null) {
          List<dynamic> result = json.decode(res.body);
          setState(() {
            addBooks.clear();
            result.forEach((book) {
              addBooks.add(Book.addFromJson(book));
            });
          });
        }
      });
    } else {
      addBooks.clear();
    }
  }

  Widget _bookList() {
    return ListView.builder(
        itemCount: addBooks.length,
        itemBuilder: (context, index) {
          final item = addBooks[index];
          return InkWell(
              child: Card(
            child: getBook(item, addButton(item)),
            color: cardBackgroundColor,
          ));
        });
  }

  Widget addButton(book) {
    if (books.map((b) => b.bookId).toList().contains(book.bookId)) {
      return IconButton(
        icon: Icon(
          Icons.check_circle,
          color: addedColor,
        ),
        onPressed: () {},
      );
    } else {
      return IconButton(
          icon: Icon(
            Icons.check_circle_outline,
            color: addableColor,
          ),
          onPressed: () {
            setState(() {
              final body = book.toJson();
              books.add(book);
              Api.post('books', body);
            });
          });
    }
  }
}
