import 'dart:convert';

import 'package:Stuff_Pages/request/entities/todo.dart';
import 'package:Stuff_Pages/request/entities/todoType.dart';
import 'package:Stuff_Pages/todo/add_todo.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../navigator.dart';
import '../request/http.dart';
import '../utils/colorUtil.dart';
import '../utils/todoUtil.dart';

class Todos extends StatefulWidget {
  @override
  _TodosState createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  List<Todo> _todos = [];
  List<Todo> filterTodos = [];
  List<TodoType> types = [];
  TodoType actualType;
  TodoType doneType = TodoType.fromJson({
    "id": null,
    "name": "Kész"
  });

  Map<TodoType, int> todoTypeMap = {};

  _getTodoTypes() {
    if (types.isEmpty) {
      Api.get("todotype/").then((res) {
        Iterable list = json.decode(res.body);
        types = list.map((e) => TodoType.fromJson(e)).toList();
        types.sort((a, b) => a.id.compareTo(b.id));
        types.add(doneType);
        actualType = types[0];
        _getTodos();
      });
    }
  }

  _getTodos() {
    Api.get("todo/").then((res) {
      Iterable list = json.decode(res.body);
      _todos = list.map((e) => Todo.fromJson(e)).toList();
      _todos.sort((a, b) => a.name.compareTo(b.name));
      filter();
      _calculateTodoTypeMap();
    });
  }

  _calculateTodoTypeMap() {
    todoTypeMap = {};
    todoTypeMap.putIfAbsent(doneType, () => _todos.where((e) => e.done != null).length);
    for (TodoType type in types) {
      todoTypeMap.putIfAbsent(type, () => _todos
              .where((e) => e.typeId == type.id && e.done == null)
              .length);
    }
  }

  @override
  void initState() {
    super.initState();
    _getTodoTypes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void filter() {
    if (actualType.id != null) {
      filterTodos = _todos
          .where((e) => e.typeId == actualType.id && e.done == null)
          .toList();
    } else {
      filterTodos = _todos.where((e) => e.done != null).toList();
    }
    setState(() {});
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
      bottomNavigationBar: MyNavigator(6),
      backgroundColor: backgroundColor,
    );
  }

  Widget titleWidget() {
    List<DropdownMenuItem> items = getDropdownMenuItem(types, todoTypeMap, true);
    return DropdownButton(
        isExpanded: true,
        value: actualType,
        items: items,
        onChanged: (type) {
          actualType = type;
          filter();
        });
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
          title: Text(todo.name, style: TextStyle(color: fontColor)),
          subtitle: Text(getType(todo), style: TextStyle(color: fontColor)),
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

  String getType(Todo todo) {
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

  void doneTodo(Todo todo) {
    if (todo.done == null) {
      todo.done = DateTime.now().toString();
    } else {
      todo.done = null;
    }
    Api.put("todo/", todo, todo.id);
    _calculateTodoTypeMap();
    filter();
  }

  void deleteTodo(Todo todo) {
    Api.deleteWithParam("todo/", todo.id);
    _todos.remove(todo);
    filterTodos.remove(todo);
    _calculateTodoTypeMap();
  }

  void doLogout() {
    setState(() {
      resetStorage();
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void doOptions() {
    setState(() {
      Navigator.pushReplacementNamed(context, '/options');
    });
  }
}
