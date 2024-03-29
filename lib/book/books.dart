import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/request/entities/book.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/bookUtil.dart';
import 'package:stuff_pages/utils/colorUtil.dart';

import '../global.dart';
import '../navigator.dart';
import 'add_book.dart';

class Books extends StatefulWidget {
  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  List<Book> _books = [];
  List<Book> filterBooks = [];
  String titleFilter = "";
  bool filterMode = false;

  _getBooks() {
    filterBooks.clear();
    Api.get("books/").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _books = list.map((e) => Book.fromJson(e)).toList();
        doFilter();
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

  void titleField(String text) {
    titleFilter = text;
    filter();
  }

  void filter() {
    filterBooks.clear();
    doFilter();
    setState(() {});
  }

  void doFilter() {
    _books.sort((a, b) => int.parse(a.priority!).compareTo(int.parse(b.priority!)));
    filterBooks = _books
        .where((book) =>
            book.title!.toLowerCase().contains(titleFilter.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: titleWidget(),
        actions: <Widget>[
          filterButton(doFilterChange),
          optionsButton(doOptions),
          logoutButton(doLogout)
        ],
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
          await Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddBook()));
          _getBooks();
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: addedColor,
      ),
      bottomNavigationBar: CustomNavigator(MenuEnum.BOOKS),
      backgroundColor: backgroundColor,
    );
  }

  Widget titleWidget() {
    if (!filterMode) {
      int booksLength = filterBooks.length;
      return Text("Könyvek ($booksLength db)", style: TextStyle(color: fontColor));
    } else {
      return searchBar("Könyv címe", titleField);
    }
  }

  Widget _bookList() {
    return ReorderableListView.builder(
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            Book drag = filterBooks[oldIndex];
            Book drop = filterBooks[newIndex];
            _books.remove(drag);

            drag.priority = drop.priority;
            Api.put("books/", drag, drag.bookId);

            _books.add(drag);
            doFilter();
          });
        },
        itemCount: filterBooks.length,
        itemBuilder: (context, index) {
          final item = filterBooks[index];
          return Dismissible(
              key: ValueKey(item.id),
              onDismissed: (direction) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(item.title! + ' törölve')));
                setState(() {
                  deleteBook(item);
                });
              },
              background: Container(color: deleteColor),
              child: InkWell(
                onTap: () {},
                key: ValueKey(item.id),
                child: Card(
                  child: getBook(item, deleteButton(item)),
                  color: cardBackgroundColor,
                ),
              ));
        });
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

  void doFilterChange() {
    setState(() {
      filterMode = !filterMode;
    });
  }

  void doLogout() {
    setState(() {
      resetStorage();
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void doOptions() {
    setState(() {
      Navigator.pushReplacementNamed(context, MenuEnum.OPTIONS.getAsPath());
    });
  }
}
