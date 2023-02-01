import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/request/entities/todo.dart';
import 'package:stuff_pages/request/entities/todoType.dart';
import 'package:stuff_pages/todo/add_todo.dart';
import 'package:stuff_pages/utils/basicUtil.dart';

import '../global.dart';
import '../navigator.dart';
import '../request/http.dart';
import '../utils/colorUtil.dart';

class ShowTodos extends StatefulWidget {
  late TodoType todoType;
  late List<TodoType> types;
  late List<Todo> todos;

  ShowTodos(List<TodoType> types, TodoType todoType, List<Todo> todos) {
    this.todoType = todoType;
    this.types = types;
    this.todos = todos;
  }

  @override
  _TodosState createState() => _TodosState(types, todoType, todos);
}

class _TodosState extends State<ShowTodos> {
  late TodoType todoType;
  late List<Todo> todos;
  late List<TodoType> types;
  bool donefilter = false;
  List<Todo> filterTodos = [];

  Map<TodoType, int> todoTypeMap = {};

  _TodosState(List<TodoType> types, TodoType todoType, List<Todo> todos) {
    this.types = types;
    this.todoType = todoType;
    this.todos = filterAndSort(todos);
  }

  _getTodos() {
    Api.get("todo/").then((res) {
      Iterable list = json.decode(res.body);
      todos = filterAndSort(list.map((e) => Todo.fromJson(e)).toList());
      filter();
    });
  }

  @override
  void initState() {
    super.initState();
    filter();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget doneFilter() {
    return Switch(
      value: donefilter,
      onChanged: (value) {
        setState(() {
          donefilter = value;
          filter();
        });
      },
      activeTrackColor: addedColor,
      activeColor: addedColor,
      inactiveTrackColor: cardBackgroundColor,
    );
  }

  void filter() {
    if (donefilter) {
      filterTodos = todos.where((e) => e.done != null).toList();
    } else {
      filterTodos = todos.where((e) => e.done == null).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: titleWidget(),
        actions: <Widget>[
          doneFilter(),
          optionsButton(doOptions),
          logoutButton(doLogout)
        ],
        iconTheme: IconThemeData(color: fontColor),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _todoList()),
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
    return Text(todoType.name!, style: TextStyle(color: fontColor));
  }

  Widget _todoList() {
    return ListView.builder(
      itemCount: filterTodos.length,
      itemBuilder: (context, index) {
        final item = filterTodos[index];
        return InkWell(
          child: Card(
            child: getTodo(item),
            color: cardBackgroundColor,
          ),
        );
      },
    );
  }

  Widget getTodo(Todo todo) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: doneButton(todo),
          title: Text(todo.name!, style: TextStyle(color: fontColor)),
          trailing: deleteButton(todo),
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddTodo(types, todo)));
            _getTodos();
          },
        ),
      ],
    );
  }

  Widget doneButton(Todo todo) {
    return IconButton(
        icon: todo.done == null
            ? Icon(
                Icons.check_box_outline_blank,
                color: addableColor,
              )
            : Icon(
                Icons.check_box_outlined,
                color: addedColor,
              ),
        onPressed: () {
          setState(() {
            doneTodo(todo);
          });
        });
  }

  String? getType(Todo todo) {
    return types.firstWhere((e) => e.id == todo.typeId).name;
  }

  Widget deleteButton(todo) {
    return IconButton(
        icon: Icon(
          Icons.delete,
          color: deleteColor,
        ),
        onPressed: () {
          setState(() {
            deleteTodo(todo);
          });
        });
  }

  List<Todo> filterAndSort(List<Todo> todos) {
    todos = todos.where((todo) => todo.typeId == todoType.id).toList();
    todos.sort((a, b) => removeDiacritics(a.name!.toLowerCase())
        .compareTo(removeDiacritics(b.name!.toLowerCase())));
    return todos;
  }

  void doneTodo(Todo todo) {
    if (todo.done == null) {
      todo.done = DateTime.now().toString();
      showToast(context, todo.name! + " kész!");
    } else {
      todo.done = null;
      showToast(context, todo.name! + " nincs kész!");
    }
    Api.put("todo/", todo, todo.id);
    filter();
  }

  void deleteTodo(Todo todo) {
    Api.deleteWithParam("todo/", todo.id);
    showToast(context, todo.name! + " törölve!");
    todos.remove(todo);
    filterTodos.remove(todo);
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
