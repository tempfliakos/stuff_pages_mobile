import 'package:flutter/material.dart';

void showToast(BuildContext context, String message) {
  ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(SnackBar(
    content: Text(message)
  ));
}
