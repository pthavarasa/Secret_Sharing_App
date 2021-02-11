import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';
import 'package:secret_share/dataStore.dart';
import 'package:secret_share/nearby_connection.dart';

class Combine extends StatefulWidget {
  @override
  _CombineState createState() => _CombineState();
}

class _CombineState extends State<Combine> {
  String combinedSecret = 'Combined secret :)';
  List<String> secretItems = List<String>();
  List<String> secretItemsList = List<String>();
  List<String> titleItems = List<String>();
  List<String> titleItemsList = List<String>();
  DataStore secret = DataStore(key: 'secret');
  DataStore title = DataStore(key: 'title');
  Connection connec = Connection();
  bool isSwitchedAdvertising = false;
  List<DropdownMenuItem<int>> titleItemsMenu = [];
  int selectedTitleItems;

  void loadtitleItemsMenu() {
    titleItemsMenu = [];
    titleItems.asMap().forEach((key, value) {
      titleItemsMenu.add(DropdownMenuItem(
        child: Text(value),
        value: key,
      ));
    });
  }

  @override
  void initState(){
    super.initState();
    secret.getData().then((value) => setState(() => secretItems = value ));
    title.getData().then((value) => setState(() => titleItems = value ));
    connec.receivedString((str){
      List<String> data = List<String>.from(jsonDecode(str));
      setState(() {
        titleItems.add(data[0]);
        secretItems.add(data[1]);
      });
    });
    connec.setContext(context);
  }

  @override
  void dispose(){
    connec.stopAllEndpoints();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loadtitleItemsMenu();
    return Scaffold(
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: Text('Make Connection'),
              subtitle: isSwitchedAdvertising? 
                Text("Advertising for device") : 
                Text("Stopped advertising"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Switch(
                    value: isSwitchedAdvertising,
                    onChanged: (value){
                      setState(() {
                        isSwitchedAdvertising = value;
                      });
                      if(value){
                        connec.permissionsHandling();
                        connec.startAdvertising();
                      }else{
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
                          connec.connectionAboutDialog(context)
                      );
                    },
                  ),
                ]
              )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton(
                hint: new Text('Select your share'),
                items: titleItemsMenu,
                value: selectedTitleItems,
                onChanged: (value) {
                  setState(() {
                    selectedTitleItems = value;
                  });
                }
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 25.0,
                  color: Colors.brown[900],
                ),
                onPressed: () {
                  setState(() {
                    titleItemsList.add(titleItems[selectedTitleItems]);
                    secretItemsList.add(secretItems[selectedTitleItems]);
                  });
                },
              ),
            ]
          ),
          Expanded(
            child: ListView.builder(
              itemCount: titleItemsList.length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    onLongPress: (){},
                    title: Text(titleItemsList[index]),
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
                              titleItemsList.removeAt(index);
                              secretItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20.0
            )
          ),
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
          Padding(
            padding: EdgeInsets.only(
              top: 20.0
            )
          ),
          Card(
            child: ListTile(
              title: Text(combinedSecret),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                ]
              )
            ),
          ),
        ]
      )
    );
  }

  void shareCombine(){
    setState(() => combinedSecret = SSS().combine(secretItemsList, true));
  }
}