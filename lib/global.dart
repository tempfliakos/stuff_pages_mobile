import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stuff_pages/utils/colorUtil.dart';

final LocalStorage userStorage = new LocalStorage('user');

int selectedIndex = 0;

Widget logoutButton(Function onPressed) {
  return IconButton(
      icon: Icon(
        Icons.power_settings_new,
        color: deleteColor,
      ),
      onPressed: () => onPressed());
}

Widget optionsButton(Function onPressed) {
  return IconButton(
      icon: Icon(
        Icons.settings,
        color: addableColor,
      ),
      onPressed: () => onPressed());
}

Widget filterButton(Function onPressed) {
  return IconButton(
      icon: Icon(
        Icons.search,
        color: addableColor,
      ),
      onPressed: () => onPressed());
}

TextField searchBar(String label, Function onChange, [isIcon = true]) {
  return TextField(
    autofocus: true,
    decoration: getSearchBarInput(label, isIcon),
    onChanged: (text) => onChange(text),
  );
}

InputDecoration getSearchBarInput(String label, isIcon) {
  if (isIcon) {
    return InputDecoration(icon: Icon(Icons.search), labelText: label);
  }
  return InputDecoration(labelText: label);
}

void resetStorage() {
  userStorage.deleteItem('user');
  userStorage.deleteItem('options');
}
