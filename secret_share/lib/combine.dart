import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';
import 'package:secret_share/dataStore.dart';
import 'package:secret_share/nearby_connection.dart';
import 'package:secret_share/secret.dart';

//List<String> secretItemsList = List<String>();
//List<String> titleItemsList = List<String>();
List<Secret> itemsList = List<Secret>();

class Combine extends StatefulWidget {
  @override
  _CombineState createState() => _CombineState();
}

class _CombineState extends State<Combine> {
  String combinedSecret = 'Combined secret :)';
  //List<String> secretItems = List<String>();
  //List<String> titleItems = List<String>();
  List<Secret> items = List<Secret>();
  //DataStore secret = DataStore(key: 'secret');
  //DataStore title = DataStore(key: 'title');
  DataStore secrets = DataStore(key: 'secrets');
  Connection connec = Connection();
  bool isSwitchedAdvertising = false;
  List<DropdownMenuItem<int>> titleItemsMenu = [];
  int selectedTitleItems;

  void loadtitleItemsMenu() {
    titleItemsMenu = [];
    items.asMap().forEach((key, value) {
      titleItemsMenu.add(DropdownMenuItem(
        child: Text(value.title),
        value: key,
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    //secret.getData().then((value) => setState(() => secretItems = value));
    //title.getData().then((value) => setState(() => titleItems = value));
    secrets.getData().then((value) => setState(() {
          value.asMap().forEach((index, element) {
            items.add(Secret.fromJson(jsonDecode(element)));
          });
        }));
    connec.receivedString((str) {
      setState(() => items.add(Secret.fromJson(jsonDecode(str))));
    });
    connec.setContext(context);
  }

  @override
  void dispose() {
    connec.stopAllEndpoints();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loadtitleItemsMenu();
    return Scaffold(
        body: Column(children: [
      Card(
        child: ListTile(
            title: Text('Make Connection'),
            subtitle: isSwitchedAdvertising
                ? Text("Advertising for device")
                : Text("Stopped advertising"),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Switch(
                value: isSwitchedAdvertising,
                onChanged: (value) {
                  setState(() {
                    isSwitchedAdvertising = value;
                  });
                  if (value) {
                    connec.permissionsHandling();
                    connec.startAdvertising();
                  } else {
                    connec.stopAdvertising();
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 25.0,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          connec.connectionAboutDialog(context));
                },
              ),
            ])),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        DropdownButton(
            hint: new Text('Select your share'),
            items: titleItemsMenu,
            value: selectedTitleItems,
            onChanged: (value) {
              setState(() {
                selectedTitleItems = value;
              });
            }),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            size: 25.0,
            color: Colors.brown[900],
          ),
          onPressed: () {
            if (selectedTitleItems != null)
              setState(() {
                //titleItemsList.add(titleItems[selectedTitleItems]);
                //secretItemsList.add(secretItems[selectedTitleItems]);
                itemsList.add(items[selectedTitleItems]);
              });
            else
              connec.showSnackbar('Select share before add!');
          },
        ),
      ]),
      Expanded(
          child: ListView.builder(
        itemCount: itemsList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              onLongPress: () {},
              title: Text(itemsList[index].title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20.0,
                      color: Colors.brown[900],
                    ),
                    onPressed: () {
                      setState(() {
                        //titleItemsList.removeAt(index);
                        //secretItemsList.removeAt(index);
                        itemsList.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      )),
      Padding(padding: EdgeInsets.only(top: 20.0)),
      MaterialButton(
        onPressed: shareCombine,
        color: Colors.blue,
        textColor: Colors.white,
        child: Icon(
          Icons.animation,
          size: 24,
        ),
        padding: EdgeInsets.all(16),
        shape: CircleBorder(),
      ),
      Padding(padding: EdgeInsets.only(top: 20.0)),
      Card(
        child: ListTile(
            title: Text(combinedSecret),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.copy,
                  size: 25.0,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: combinedSecret));
                  connec.showSnackbar('Secret copied to clipboard');
                },
              ),
            ])),
      ),
    ]));
  }

  void shareCombine() {
    if (itemsList.isNotEmpty) {
      try {
        String cs =
            SSS().combine(itemsList.map((val) => val.share).toList(), true);
        setState(() => combinedSecret = cs);
      } on Exception catch (e) {
        connec.showSnackbar(e);
      }
    } else
      connec.showSnackbar('Invalid shares, add shares!');
  }
}
