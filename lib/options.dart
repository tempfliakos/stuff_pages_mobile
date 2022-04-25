import 'package:Stuff_Pages/global.dart';
import 'package:Stuff_Pages/utils/colorUtil.dart';
import 'package:Stuff_Pages/utils/optionsUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'navigator.dart';

class Options extends StatefulWidget {
  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  Map<String, Object> options;

  var optionsValue = {
    'defaultPage': [
      '/movies',
      '/books',
      '/xbox',
      '/playstation',
      '/switch',
      '/wish'
    ],
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
      body: Center(
        child: Column(
          children: [getDropdowns()],
        ),
      ),
      bottomNavigationBar: MyNavigator(0),
      backgroundColor: backgroundColor,
    );
  }

  Widget getDropdowns() {
    options = getOptions();
    List<TableRow> rows = [];
    for (var option in options.keys) {
      rows.addAll(getRows(option));
    }
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  List<TableRow> getRows(option) {
    List<TableRow> result = [];
    result.add(TableRow(children: [
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            child: Text(optionsName[option], style: TextStyle(color: fontColor)),
          )),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            child: getDropDown(option),
          ))
    ]));
    return result;
  }

  Widget getDropDown(optionsKey) {
    return DropdownButton(
        value: options[optionsKey],
        items: getDropdownMenuItem(optionsKey),
        onChanged: (newValue) {
          setState(() {
            options[optionsKey] = newValue;
            userStorage.setItem('options', options);
          });
        });
  }

  List<DropdownMenuItem> getDropdownMenuItem(optionsKey) {
    List<Object> options = optionsValue[optionsKey];
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
        default:
          if (option != null) {
            text = option ? 'Megjelenít' : 'Elrejt';
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
}
