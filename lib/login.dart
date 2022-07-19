import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:stuff_pages/register.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/optionsUtil.dart';

import 'global.dart';
import 'request/http.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  initState() {
    super.initState();
    _getLoggedIn();
  }

  _getLoggedIn() {
    userStorage.ready.then((value) {
      if (userStorage.getItem('user') != null) {
        Map<String, Object> options = getOptions();
        Navigator.pushReplacementNamed(
            context, options['defaultPage'].toString());
      }
    });
  }

  dispose() {
    super.dispose();
  }

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  Widget emailField() {
    return TextFormField(
      controller: emailEditingController,
      validator: (value) =>
          EmailValidator.validate(value) ? null : "Kérlek valós emailt adj meg",
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Email megadása',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget passwordField() {
    return TextFormField(
      controller: passwordEditingController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Jelszó megadása';
        }
        return null;
      },
      maxLines: 1,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        hintText: 'Jelszó megadása',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget loginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState.validate()) {
          _login();
        }
      },
      style: ElevatedButton.styleFrom(
        primary: cardBackgroundColor,
        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
      ),
      child: const Text(
        'Bejelentkezés',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  _login() async {
    final body = {'email': emailEditingController.text, 'password': passwordEditingController.text};
    final result = await Api.post('auth/login', body);
    userStorage.setItem('user', jsonDecode(result.body)['accessToken']);
    Map<String, Object> options = getOptions();
    Navigator.pushReplacementNamed(context, options['defaultPage'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bejelentkezés',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  emailField(),
                  const SizedBox(
                    height: 20,
                  ),
                  passwordField(),
                  const SizedBox(
                    height: 20,
                  ),
                  loginButton(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Még nem regisztráltál?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        child: const Text('Profil létrehozása'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
