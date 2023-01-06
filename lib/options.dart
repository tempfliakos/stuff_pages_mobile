import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stuff_pages/enums/menuEnum.dart';
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
  TextEditingController typeAddingController = TextEditingController();

  Map systemOptions = {
    'defaultPage': [
      MenuEnum.MOVIES.getAsPath(),
      MenuEnum.BOOKS.getAsPath(),
      MenuEnum.XBOX_GAMES.getAsPath(),
      MenuEnum.PS_GAMES.getAsPath(),
      MenuEnum.SWITCH_GAMES.getAsPath(),
      MenuEnum.WISHLIST.getAsPath(),
      MenuEnum.TODOS.getAsPath(),
      MenuEnum.OPTIONS.getAsPath()
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
            Text('Rendszerbeállítások',
                style: TextStyle(color: fontColor, fontSize: 24.0)),
            getDropdowns(systemOptions),
            const SizedBox(
              height: 20,
            ),
            Text('Film beállítások',
                style: TextStyle(color: fontColor, fontSize: 24.0)),
            getDropdowns(movieOptions),
            const SizedBox(
              height: 20,
            ),
            Text('Feladat típusok',
                style: TextStyle(color: fontColor, fontSize: 24.0)),
            Column(
              children: getTypes(),
            ),
            Column(
              children: [newTypeField(), typeAddingButton()],
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigator(MenuEnum.MOVIES),
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
    List<dynamic> options = suboptions[optionsKey];
    List<DropdownMenuItem> result = [];
    for (var option in options) {
      var text;
      if (option == MenuEnum.MOVIES.getAsPath()) {
        text = 'Filmek';
      } else if (option == MenuEnum.BOOKS.getAsPath()) {
        text = 'Könyvek';
      } else if (option == MenuEnum.XBOX_GAMES.getAsPath()) {
        text = 'Xbox játékok';
      } else if (option == MenuEnum.PS_GAMES.getAsPath()) {
        text = 'Playstation játékok';
      } else if (option == MenuEnum.SWITCH_GAMES.getAsPath()) {
        text = 'Switch játékok';
      } else if (option == MenuEnum.WISHLIST.getAsPath()) {
        text = 'Wishlist';
      } else if (option == MenuEnum.TODOS.getAsPath()) {
        text = 'Feladatok';
      } else if (option == MenuEnum.OPTIONS.getAsPath()) {
        text = 'Beállítások';
      } else {
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
      result.add(
          Text(type.name!, style: TextStyle(color: fontColor, fontSize: 16.0)));
    }
    return result;
  }

  Widget newTypeField() {
    return TextFormField(
      controller: typeAddingController,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Új típus megadása',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget typeAddingButton() {
    return ElevatedButton(
      onPressed: () {
        _createType();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: cardBackgroundColor,
        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
      ),
      child: const Text(
        'Hozzáadás',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _createType() async {
    String? name = typeAddingController.text;
    if (typeIsValid(name)) {
      final TodoType todoType = TodoType();
      setState(() {
        todoType.name = typeAddingController.text;
        Api.post('todotype', todoType.toJson());
        types.add(todoType);
        getTypes();
        typeAddingController = TextEditingController();
      });
    }
  }

  bool typeIsValid(String? name) {
    if (name == null || name.isEmpty) {
      return false;
    }
    for (var type in types) {
      if (type.name == name) {
        return false;
      }
    }
    return true;
  }
}
