import 'dart:convert';

import 'package:http/http.dart' as http;

import '../global.dart';

//const URL = 'http://192.168.99.18:3001/';
const URL = 'https://stuff-pages-server.herokuapp.com/';

const IMDB =
    'https://api.themoviedb.org/4/search/movie?api_key=05290ff40fe203e2de4b0e9f832245e1&language=hu';

class Api {
  static Future get(String endpoint, String userId) {
    return http.get(URL + endpoint + userId);
  }

  static Future getAddMovie(String title) {
    final params = {
      'api_key': '05290ff40fe203e2de4b0e9f832245e1',
      'language': 'hu',
      'query': title,
    };
    final uri = new Uri.https('api.themoviedb.org', '/4/search/movie', params);
    return http.get(uri, headers: <String, String>{
      'Accept': 'application/json',
    }).catchError((onError) {
      print(onError);
    });
  }

  static Future post(String endpoint, body) {
    final url = URL + endpoint;
    return http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body));
  }

  static Future delete(String endpoint, body) async {
    final url = URL + endpoint + body.id;
    http.Request rq = http.Request('DELETE', Uri.parse(url));
    rq.bodyFields = {
      'id': body.id,
      'user_id': userStorage.getItem('user')
    };
    return await http.Client().send(rq);
  }

  static Future put(String endpoint, body, id) {
    final url = URL + endpoint + id;
    body.userId = userStorage.getItem('user');
    return http.put(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body));
  }
}
