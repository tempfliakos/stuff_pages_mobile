import 'package:stuff_pages/enums/menuEnum.dart';
import 'package:stuff_pages/global.dart';

Map<String, Object?> defaultOptions = {
  'defaultPage': MenuEnum.MOVIES.getAsPath(),
  'defaultSeen': null,
  'defaultOwn': null,
  'defaultFuture': null,
  'defaultLiza': null,
};

setDefault() {
  userStorage.setItem('options', defaultOptions);
}

Map<String, Object?> getOptions() {
  Map<String, Object?>? options = userStorage.getItem('options');
  if (options == null) {
    return defaultOptions;
  }
  return options;
}
