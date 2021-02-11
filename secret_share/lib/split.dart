import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';
import 'package:secret_share/dataStore.dart';
import 'package:secret_share/nearby_connection.dart';

class Split extends StatefulWidget {
  @override
  _SplitState createState() => _SplitState();
}

class _SplitState extends State<Split> {
  List<String> items = List<String>();
  final titleController = TextEditingController();
  final secretController = TextEditingController();
  List<String> arr = List<String>();
  DataStore title = DataStore(key: 'title');
  DataStore secret = DataStore(key: 'secret');
  Connection connec = Connection();
  bool isSwitchedAdvertising = false;
  int threshold = 2;
  int shares = 3;

  @override
  void initState(){
    super.initState();
    connec.setContext(context);
  }

  @override
  void dispose(){
    connec.stopAllEndpoints();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.0),
      child: Column(
        children: <Widget>[
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
          Padding(
            padding: EdgeInsets.only(
              top: 20.0
            )
          ),
          TextField(
            controller: titleController,
            autofocus: false,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(), 
              labelText: 'Title'
            )
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20.0
            )
          ),
          TextField(
            controller: secretController,
            maxLines: null,
            autofocus: false,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(), 
              labelText: 'Secret to crypt'
            )
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20.0
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Threshold'),
              CustomNumberPicker(
                initialValue: 2,
                maxValue: 10,
                minValue: 0,
                step: 1,
                onValue: (value) {
                  //print(value.toString());
                  setState(() {
                    threshold = value;
                  });
                },
              ),
              Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0)),
              CustomNumberPicker(
                initialValue: 3,
                maxValue: 20,
                minValue: 0,
                step: 1,
                onValue: (value) {
                  //print(value.toString());
                  setState(() {
                    shares = value;
                  });
                },
              ),
              Text('Shares')
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20.0
            )
          ),
          MaterialButton(
            onPressed: _splitShares,
            color: Colors.blue,
            textColor: Colors.white,
            child: Icon(
              Icons.alt_route_sharp,
              size: 24,
            ),
            padding: EdgeInsets.all(16),
            shape: CircleBorder(),
          ),
          Expanded(
                child : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: (){},
                        title: Text(items[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.save_alt,
                                size: 20.0,
                                color: Colors.brown[900],
                              ),
                              onPressed: () async {
                                title.updateData(items[index]);
                                secret.updateData(arr[index]);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                size: 20.0,
                                color: Colors.brown[900],
                              ),
                              onPressed: () async {
                                connec.sendString(jsonEncode([items[index], arr[index]]));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
    );
  }

  void _splitShares(){
    if(titleController.text != ''){
      if(secretController.text != ''){
        if(threshold <= shares){
          setState(() {
            items.clear();
          });
          SSS sss = SSS();
          arr = sss.create(threshold, shares, secretController.text, true);
          arr.asMap().forEach((index, element) {
            setState(() {
              items.add(titleController.text + '-' + index.toString());
            });
          });
        }else connec.showSnackbar('Threshold should be less than shares !');
      }else connec.showSnackbar('Input Required : Secret !');
    }else connec.showSnackbar('Input Required : Title !');
  }
}