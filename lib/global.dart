import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

final LocalStorage userStorage = new LocalStorage('user');

var selectedIndex = 0;

Widget logoutButton(context, setState) {
  return IconButton(
      icon: Icon(
        Icons.power_settings_new,
        color: Colors.red,
      ),
      onPressed: () {
        setState(() {
          userStorage.deleteItem('user');
          Navigator.pushReplacementNamed(context, '/');
        });
      });
}