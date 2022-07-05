import 'package:Stuff_Pages/request/entities/todoType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../request/entities/todo.dart';
import '../request/http.dart';
import '../utils/colorUtil.dart';
import '../utils/todoUtil.dart';

class AddTodo extends StatefulWidget {
  List<TodoType> types;
  Todo actual;

  AddTodo(List<TodoType> types, Todo actual) {
    this.types = types;
    this.actual = actual;
  }

  @override
  _AddTodoState createState() => _AddTodoState(types, actual);
}

class _AddTodoState extends State<AddTodo> {
  List<TodoType> types;
  Todo actual;
  TodoType actualType;
  final _formKey = GlobalKey<FormState>();

  _AddTodoState(List<TodoType> types, Todo actual) {
    this.types = types;
    this.actual = actual;
    if (actual.id == null) {
      actualType = types[0];
    } else {
      actualType = getType(actual);
      nameEditingController.text = actual.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: backgroundColor, title: titleField()),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  typeField(),
                  const SizedBox(
                    height: 20,
                  ),
                  nameField(),
                  const SizedBox(
                    height: 20,
                  ),
                  saveButton(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Text titleField() {
    if (actual.id == null) {
      return Text('Feladat hozzáadása', style: TextStyle(color: fontColor));
    }
    return Text('Feladat szerkesztése', style: TextStyle(color: fontColor));
  }

  TextEditingController nameEditingController = TextEditingController();

  Widget nameField() {
    return TextFormField(
      controller: nameEditingController,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Feladat megadása',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  TodoType getType(Todo todo) {
    return types.firstWhere((e) => e.id == todo.typeId);
  }

  Widget typeField() {
    return DropdownButton(
        isExpanded: true,
        value: actualType,
        items: getDropdownMenuItem(types, {}),
        onChanged: (type) {
          setState(() {
            actualType = type;
          });
        });
  }

  Widget saveButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          actual.name = nameEditingController.text;
          actual.typeId = actualType.id;
          final body = actual.toJson();
          if (actual.id == null) {
            Api.post('todo', body);
          } else {
            Api.put('todo/', body, actual.id);
          }
        });
      },
      style: ElevatedButton.styleFrom(
        primary: cardBackgroundColor,
        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
      ),
      child: titleField(),
    );
  }
}
