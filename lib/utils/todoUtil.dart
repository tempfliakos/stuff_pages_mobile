import 'package:flutter/material.dart';

import '../request/entities/todoType.dart';
import 'colorUtil.dart';

List<DropdownMenuItem> getDropdownMenuItem(List<TodoType> types, Map<TodoType, int> todoTypeMap, [bool needDone = false]) {
  List<DropdownMenuItem> result = [];
  for (TodoType type in types) {
    if(needDone || type.id != null) {
      String countText = todoTypeMap.isNotEmpty ? " (" +
          todoTypeMap[type].toString() + ")" : "";
      result.add(DropdownMenuItem(
        value: type,
        child: Text(type.name! + countText, style: TextStyle(color: fontColor)),
      ));
    }
  }
  return result;
}