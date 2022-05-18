import 'package:flutter/material.dart';

import '../request/entities/todoType.dart';
import 'colorUtil.dart';

List<DropdownMenuItem> getDropdownMenuItem(List<TodoType> types) {
  List<DropdownMenuItem> result = [];
  for (TodoType type in types) {
    result.add(DropdownMenuItem(
      value: type,
      child: Text(type.name, style: TextStyle(color: fontColor)),
    ));
  }
  return result;
}