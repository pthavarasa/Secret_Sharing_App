import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:secret_share/dataStore.dart';
import 'package:secret_share/nearby_connection.dart';
import 'package:share/share.dart';
import 'package:secret_share/secret.dart';

enum WhyFarther { send, share, saveAs }

class Receive extends StatefulWidget {
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  //List<String> secretItems = List<String>();
  //List<String> titleItems = List<String>();
  List<Secret> items = List<Secret>();
  //DataStore secret = DataStore(key: 'secret');
  //DataStore title = DataStore(key: 'title');
  DataStore secrets = DataStore(key: 'secrets');
  Connection connec = Connection();
  bool isSwitchedDiscovering = false;

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
      //List<String> data = List<String>.from(jsonDecode(str));
      //secret.updateData(data[1]);
      //title.updateData(data[0]);
      //secret.getData().then((value) => setState(() => secretItems = value));
      //title.getData().then((value) => setState(() => titleItems = value));
      setState(() => items.add(Secret.fromJson(jsonDecode(str))));
      secrets.updateData(str);
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
    return Scaffold(
        body: Column(children: [
      Card(
        child: ListTile(
            title: Text('Make Connection'),
            subtitle: isSwitchedDiscovering
                ? Text("Discovering device")
                : Text("Stopped Discovering"),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Switch(
                value: isSwitchedDiscovering,
                onChanged: (value) {
                  setState(() {
                    isSwitchedDiscovering = value;
                  });
                  if (value) {
                    connec.permissionsHandling();
                    connec.startDiscovering();
                  } else {
                    connec.stopDiscovery();
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
      Expanded(
          child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              onLongPress: () => _showDialog(index),
              title: Text(items[index].title),
              subtitle: Text(items[index].formatedDate),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20.0,
                      color: Colors.brown[900],
                    ),
                    onPressed: () async {
                      //secret.removeData(index);
                      //title.removeData(index);
                      secrets.removeData(index);
                      setState(() {
                        //titleItems.removeAt(index);
                        //secretItems.removeAt(index);
                        items.removeAt(index);
                      });
                    },
                  ),
                  PopupMenuButton<WhyFarther>(
                    onSelected: (WhyFarther result) {
                      if (result == WhyFarther.send)
                        connec.sendString(jsonEncode(items[index].toJson()));
                      if (result == WhyFarther.share)
                        Share.share(jsonEncode(items[index].toJson()),
                            subject: items[index].title);
                      if (result == WhyFarther.saveAs)
                        saveFile(items[index].title,
                            jsonEncode(items[index].toJson()));
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<WhyFarther>>[
                      PopupMenuItem<WhyFarther>(
                        value: WhyFarther.send,
                        child: Row(children: <Widget>[
                          Icon(Icons.send_sharp),
                          Padding(padding: EdgeInsets.only(left: 10.0)),
                          Text('Send'),
                        ]),
                      ),
                      PopupMenuItem<WhyFarther>(
                        value: WhyFarther.share,
                        child: Row(children: <Widget>[
                          Icon(Icons.share),
                          Padding(padding: EdgeInsets.only(left: 10.0)),
                          Text('Share'),
                        ]),
                      ),
                      PopupMenuItem<WhyFarther>(
                        value: WhyFarther.saveAs,
                        child: Row(children: <Widget>[
                          Icon(Icons.save),
                          Padding(padding: EdgeInsets.only(left: 10.0)),
                          Text('Save As'),
                        ]),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ))
    ]));
  }

  void saveFile(String fileName, String content) async {
    if (await connec.checkStoragePermission()) {
      File file = File('/storage/emulated/0/Download/$fileName.json');
      file.writeAsString(content);
      connec.showSnackbar('Secret saved as file in Download directory.');
    } else {
      connec.askStoragePermission();
    }
  }

  _showDialog(index) async {
    final myController = TextEditingController();
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: myController,
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Rename',
                    hintText: items[index].title + ' to ...'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('RENAME'),
              onPressed: () {
                setState(() {
                  items[index].title = myController.text;
                });
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}
