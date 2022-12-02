import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stuff_pages/global.dart';
import 'package:stuff_pages/request/entities/todoType.dart';
import 'package:stuff_pages/request/http.dart';
import 'package:stuff_pages/utils/colorUtil.dart';
import 'package:stuff_pages/utils/optionsUtil.dart';

import 'navigator.dart';

class Options extends StatefulWidget {
  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  late Map<String, Object?> options;
  List<TodoType> types = [];

  Map systemOptions = {
    'defaultPage': [
      '/movies',
      '/books',
      '/xbox',
      '/playstation',
      '/switch',
      '/wish',
      '/todo'
    ],
  };

  Map movieOptions = {
    'defaultSeen': [null, true, false],
    'defaultOwn': [null, true, false],
    'defaultFuture': [null, true, false],
    'defaultLiza': [null, true, false],
  };

  var optionsName = {
    'defaultPage': 'Alapértelmezett kezdőoldal',
    'defaultSeen': 'Megnézett filmek szűrő',
    'defaultOwn': 'Beszerzett filmek szűrő',
    'defaultFuture': 'Jövőbeni filmek szűrő',
    'defaultLiza': 'Liza filmek szűrő',
  };

  _getTodoTypes() {
    if (types.isEmpty) {
      Api.get("todotype/").then((res) {
        setState(() {
          Iterable list = json.decode(res.body);
          types = list.map((e) => TodoType.fromJson(e)).toList();
          types.sort((a, b) => a.id!.compareTo(b.id!));
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTodoTypes();
    options = getOptions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Text('Beállítások', style: TextStyle(color: fontColor)),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Rendszerbeállítások', style: TextStyle(color: fontColor)),
            getDropdowns(systemOptions),
            const SizedBox(
              height: 20,
            ),
            Text('Film beállítások', style: TextStyle(color: fontColor)),
            getDropdowns(movieOptions),
            const SizedBox(
              height: 20,
            ),
            Text('Feladat típusok', style: TextStyle(color: fontColor)),
            Column(
              children: getTypes(),
            )
          ],
        ),
      ),
      bottomNavigationBar: MyNavigator(0),
      backgroundColor: backgroundColor,
    );
  }

  Widget getDropdowns(Map suboptions) {
    List<TableRow> rows = [];
    for (var option in suboptions.keys) {
      rows.addAll(getRows(suboptions, option));
    }
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  List<TableRow> getRows(Map suboptions, option) {
    List<TableRow> result = [];
    result.add(TableRow(children: [
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            child:
                Text(optionsName[option]!, style: TextStyle(color: fontColor)),
          )),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            child: getDropDown(suboptions, option),
          ))
    ]));
    return result;
  }

  Widget getDropDown(Map suboptions, optionsKey) {
    return DropdownButton<dynamic>(
        isExpanded: true,
        value: options[optionsKey],
        items: getDropdownMenuItem(suboptions, optionsKey),
        onChanged: (newValue) {
          setState(() {
            options[optionsKey] = newValue;
            userStorage.setItem('options', options);
          });
        });
  }

  List<DropdownMenuItem> getDropdownMenuItem(Map suboptions, optionsKey) {
    List<Object> options = suboptions[optionsKey];
    List<DropdownMenuItem> result = [];
    for (var option in options) {
      var text;
      switch (option) {
        case '/options':
          text = 'Beállítások';
          break;
        case '/movies':
          text = 'Filmek';
          break;
        case '/books':
          text = 'Könyvek';
          break;
        case '/xbox':
          text = 'Xbox játékok';
          break;
        case '/playstation':
          text = 'Playstation játékok';
          break;
        case '/switch':
          text = 'Switch játékok';
          break;
        case '/wish':
          text = 'Wishlist';
          break;
        case '/todo':
          text = 'Feladatok';
          break;
        default:
          if (option != null) {
            text = option == true ? 'Megjelenít' : 'Elrejt';
          } else {
            text = 'Nincs beállítva';
          }
      }
      result.add(DropdownMenuItem(
        value: option,
        child: Text(text, style: TextStyle(color: fontColor)),
      ));
    }
    return result;
  }

  List<Widget> getTypes() {
    List<Text> result = [];
    for (var type in types) {
      result.add(Text(type.name!, style: TextStyle(color: fontColor)));
    }
    return result;
  }
}
