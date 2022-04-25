import 'dart:convert';

import 'package:Stuff_Pages/request/entities/book.dart';
import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/bookUtil.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';
import 'add_book.dart';

class Books extends StatefulWidget {
  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  List _books = [];
  List filterBooks = [];

  _getBooks() {
    filterBooks.clear();
    Api.get("books/").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _books = list.map((e) => Book.fromJson(e)).toList();
        _books.sort((a, b) => a.title.compareTo(b.title));
        filterBooks.addAll(_books);
      });
    });
  }

  initState() {
    super.initState();
    _getBooks();
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Text('Könyvek', style: TextStyle(color: fontColor)),
        actions: <Widget>[optionsButton(), logoutButton()],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _bookList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddBook(_books)));
          _getBooks();
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: addedColor,
      ),
      bottomNavigationBar: MyNavigator(1),
      backgroundColor: backgroundColor,
    );
  }

  Widget _bookList() {
    return ListView.builder(
      itemCount: filterBooks.length,
      itemBuilder: (context, index) {
        final item = filterBooks[index];
        return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(item.title + ' törölve')));
              setState(() {
                deleteBook(item);
              });
            },
            background: Container(color: deleteColor),
            child: InkWell(
              child: Card(
                child: getBook(item, deleteButton(item)),
                color: cardBackgroundColor,
              ),
            ));
      },
    );
  }

  Widget deleteButton(book) {
    return IconButton(
        icon: Icon(
          Icons.delete,
          color: deleteColor,
        ),
        onPressed: () {
          setState(() {
            deleteBook(book);
          });
        });
  }
  
  void deleteBook(Book book) {
    Api.deleteWithParam("books/", book.bookId);
    _books.remove(book);
    filterBooks.remove(book);
  }

  Widget logoutButton() {
    return IconButton(
        icon: Icon(
          Icons.power_settings_new,
          color: deleteColor,
        ),
        onPressed: () {
          setState(() {
            userStorage.deleteItem('user');
            userStorage.deleteItem('options');
            Navigator.pushReplacementNamed(context, '/');
          });
        });
  }

  Widget optionsButton() {
    return IconButton(
        icon: Icon(
          Icons.settings,
          color: addableColor,
        ),
        onPressed: () {
          setState(() {
            Navigator.pushReplacementNamed(context, '/options');
          });
        });
  }
}
