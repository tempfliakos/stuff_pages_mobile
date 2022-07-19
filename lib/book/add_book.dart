import 'dart:convert';

import 'package:stuff_pages/request/entities/book.dart';
import 'package:stuff_pages/utils/bookUtil.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../request/http.dart';

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  List<Book> addBooks = [];
  List<Book> books = [];

  _AddBookState() {
    Api.get("books/ids").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        books = list.map((e) => Book.addScreen(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: searchBar("Könyv hozzáadása...", findBooks),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _bookList()),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  void findBooks(text) {
    if (text.length > 2) {
      ProgressHud.showLoading();
      Api.getFromApi("books", text.toString()).then((res) {
        if (res != null) {
          List<dynamic> result = json.decode(res.body);
          setState(() {
            addBooks.clear();
            result.forEach((book) {
              addBooks.add(Book.addFromJson(book));
            });
            ProgressHud.dismiss();
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
