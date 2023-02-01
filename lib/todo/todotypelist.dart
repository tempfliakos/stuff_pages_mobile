import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/request/entities/todo.dart';
import 'package:stuff_pages/request/entities/todoType.dart';
import 'package:stuff_pages/todo/add_todo.dart';
import 'package:stuff_pages/todo/todos.dart';
import 'package:diacritic/diacritic.dart';

import '../global.dart';
import '../navigator.dart';
import '../request/http.dart';
import '../utils/colorUtil.dart';

class TodoTypeList extends StatefulWidget {
  @override
  _TodosState createState() => _TodosState();
}

class _TodosState extends State<TodoTypeList> {
  late List<TodoType> types;
  late List<Todo> _todos;
  Map<TodoType, int> todoTypeMap = {};

  _getTodoTypes() {
    Api.get("todotype/").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        types = list.map((e) => TodoType.fromJson(e)).toList();
        types.sort((a, b) =>
            removeDiacritics(a.name!).compareTo(removeDiacritics(b.name!)));
      });
    });
  }

  _getTodos() {
    Api.get("todo/").then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        _todos = list.map((e) => Todo.fromJson(e)).toList();
        _todos.sort((a, b) =>
            removeDiacritics(a.name!).compareTo(removeDiacritics(b.name!)));
        _calculateTodoTypeMap();
      });
    });
  }

  _calculateTodoTypeMap() {
    todoTypeMap = {};
    for (TodoType type in types) {
      todoTypeMap.putIfAbsent(
          type, () => _todos.where((e) => e.typeId == type.id).length);
    }
  }

  @override
  void initState() {
    super.initState();
    _getTodoTypes();
    _getTodos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: titleWidget(),
        actions: <Widget>[optionsButton(doOptions), logoutButton(doLogout)],
        iconTheme: IconThemeData(color: fontColor),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _todoTypeList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddTodo(types, new Todo())));
          _getTodos();
        },
        child: Icon(Icons.add, size: 40),
        backgroundColor: addedColor,
      ),
      bottomNavigationBar: CustomNavigator(MenuEnum.TODOS),
      backgroundColor: backgroundColor,
    );
  }

  Widget titleWidget() {
    return Text('Feladatok', style: TextStyle(color: fontColor));
  }

  Widget _todoTypeList() {
    print("_todoTypeList");
    print(types.length);
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(types.length, (index) {
        TodoType actual = types[index];
        return InkWell(
          child: Card(child: getTodoType(actual), color: cardBackgroundColor),
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShowTodos(types, actual, _todos)));
          },
        );
      }),
    );
  }

  Widget getTodoType(TodoType todoType) {
    return SizedBox(
        width: 1,
        height: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Center(child: Text(todoType.name!))],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text("Összesen: " +
                        _todos
                            .where((e) => e.typeId == todoType.id)
                            .length
                            .toString() +
                        " db"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text("Kész: " +
                        _todos
                            .where((e) =>
                                e.typeId == todoType.id && e.done != null)
                            .length
                            .toString() +
                        " db"))
              ],
            )
          ],
        ));
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
