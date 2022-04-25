import 'dart:convert';

import 'package:http/http.dart' as http;

import '../global.dart';

const URL = 'http://localhost:3001/';
//const URL = 'https://stuff-pages-server.herokuapp.com/';

class Api {
  static Future get(String endpoint) {
    return http.get(Uri.parse(URL + endpoint), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${userStorage.getItem('user')}'
    });
  }

  static Future post(String endpoint, body) {
    return http.post(Uri.parse(URL + endpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userStorage.getItem('user')}'
        },
        body: jsonEncode(body));
  }

  static Future getFromApi(String endpoint, String data) {
    Uri uri = Uri.parse(URL + "endpoint/" + endpoint + "/query=" + data);
    return http.get(uri, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${userStorage.getItem('user')}'
    }).catchError((onError) {
      print(onError);
    });
  }

  static Future delete(String endpoint, body) async {
    return http.delete(Uri.parse(URL + endpoint + body.id), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${userStorage.getItem('user')}'
    });
  }

  static Future deleteWithParam(String endpoint, param) async {
    Uri uri = Uri.parse(URL + endpoint + param);
    print(uri);
    return http.delete(uri, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${userStorage.getItem('user')}'
    });
  }

  static Future put(String endpoint, body, id) {
    return http
        .put(Uri.parse(URL + endpoint + id),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ${userStorage.getItem('user')}'
            },
            body: jsonEncode(body))
        .catchError((onError) {
      print(onError);
    });
  }
}
