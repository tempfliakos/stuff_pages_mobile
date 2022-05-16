import 'package:Stuff_Pages/request/http.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController rePasswordEditingController = TextEditingController();

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
        if (value == null || value.isEmpty || rePasswordEditingController.text != value) {
          return 'A 2 jelszó nem egyezik';
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

  Widget rePasswordField() {
    return TextFormField(
        controller: rePasswordEditingController,
      validator: (value) {
        if (value == null || value.isEmpty || passwordEditingController.text != value) {
          return 'A 2 jelszó nem egyezik';
        }
        return null;
      },
      maxLines: 1,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        hintText: 'Jelszó megadása újra',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget registerButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState.validate()) {
          _register();
        }
      },
      style: ElevatedButton.styleFrom(
        primary: cardBackgroundColor,
        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
      ),
      child: const Text(
        'Regisztráció',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _register() async {
    final body = {'email': emailEditingController.text, 'password': passwordEditingController.text};
    final result = await Api.post('auth/register', body);
    Navigator.pushReplacementNamed(context, '/');
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
              'Regisztráció',
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
                  rePasswordField(),
                  const SizedBox(
                    height: 20,
                  ),
                  registerButton(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Már regisztrálva?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );
                        },
                        child: const Text('Bejelentkezés'),
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
