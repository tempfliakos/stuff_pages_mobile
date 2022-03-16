import 'package:Stuff_Pages/global.dart';

Map<String, Object> defaultOptions = {
  'defaultPage': '/movies',
  'defaultSeen': null,
  'defaultOwn': null,
  'defaultFuture': null,
  'defaultLiza': null,
};

setDefault() {
  userStorage.setItem('options', defaultOptions);
}

Map<String, Object> getOptions() {
  Map<String, Object> options = userStorage.getItem('options');
  if (options == null) {
    return defaultOptions;
  }
  return options;
}
