import 'dart:convert';

import 'package:flutter/material.dart';

import 'global.dart';
import 'request/http.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

final TextEditingController _email = TextEditingController();
final TextEditingController _pwd = TextEditingController();

class _LoginState extends State<Login> {
  initState() {
    super.initState();
    _getLoggedIn();
  }

  _getLoggedIn() {
    userStorage.ready.then((value) {
      if (userStorage.getItem('user') != null) {
        Navigator.pushReplacementNamed(context, '/movies');
      }
    });
  }

  dispose() {
    super.dispose();
  }

  Widget emailField() {
    return TextField(
      obscureText: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'E-mail',
      ),
      autofocus: true,
      controller: _email,
    );
  }

  Widget passwordField() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Jelszó',
      ),
      controller: _pwd,
    );
  }

  Widget loginButton(BuildContext context) {
    return TextButton(
      child: Text("Bejelentkezés", style: TextStyle(color: Colors.white)),
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
      onPressed: () {
        _login();
      },
    );
  }

  _login() async {
    final body = {'email': _email.text, 'password': _pwd.text};
    final result = await Api.post('auth/login', body);
    userStorage.setItem('user', jsonDecode(result.body)['accessToken']);
    Navigator.pushReplacementNamed(context, '/movies');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Text('Bejelentkezés')),
      body: Center(
        child: Column(
          children: <Widget>[
            emailField(),
            passwordField(),
            loginButton(context)
          ],
        ),
      ),
      backgroundColor: Colors.grey,
    );
  }
}
