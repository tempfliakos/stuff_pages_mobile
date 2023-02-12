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
  _TodoTyepeState createState() => _TodoTyepeState();
}

class _TodoTyepeState extends State<TodoTypeList> {
  List<TodoType> types = [];
  List<Todo> _todos = [];
  Map<TodoType, int> todoTypeMap = {};

  Future<dynamic> _getTodoTypes() {
    return Api.get("todotype/");
  }

  Future<dynamic> _getTodos() {
    return Api.get("todo/");
  }

  _calculateTodoTypeMap() {
    todoTypeMap = {};
    for (TodoType type in types) {
      todoTypeMap.putIfAbsent(
          type, () => _todos.where((e) => e.typeId == type.id).length);
    }
  }

  Future<void> initLists() async {
    final result = await Future.wait([_getTodoTypes(), _getTodos()]);
    Iterable typeList = json.decode(result[0].body);
    types = typeList.map((e) => TodoType.fromJson(e)).toList();
    types.sort((a, b) =>
        removeDiacritics(a.name!).compareTo(removeDiacritics(b.name!)));

    Iterable todoList = json.decode(result[1].body);
    _todos = todoList.map((e) => Todo.fromJson(e)).toList();
    _todos.sort((a, b) =>
        removeDiacritics(a.name!).compareTo(removeDiacritics(b.name!)));
    _calculateTodoTypeMap();
  }

  @override
  void initState() {
    super.initState();
    initLists().whenComplete(() => setState((){}));
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
