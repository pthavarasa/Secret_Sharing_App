import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Split extends StatefulWidget {
  @override
  _SplitState createState() => _SplitState();
}

class _SplitState extends State<Split> {
  List<String> items = List<String>();
  final myController = TextEditingController();
  List<String> arr = List<String>();
  int threshold = 2;
  int shares = 3;
  void _splitShares(){
    if(myController.text != ''){
      if(threshold <= shares){
        //print(myController.text);
        setState(() {
          items.clear();
        });
        SSS sss = new SSS();
        //print("secret: ${myController.text}");
        //print("secret.length: ${myController.text.length}");
        arr = sss.create(threshold, shares, myController.text, true);
        //print(arr);
        arr.asMap().forEach((index, element) {
          setState(() {
            items.add('Secret ' + index.toString());
          });
        });
      }else{
        print('threshold should be less than shares!');
      }
    }else{
      print('Split share button was clicked but the secret texedfeild was empty!');
    }
  }

  final String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_STAR;

  String cId = "0"; //currently connected device ID

  void showSnackbar(dynamic a) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          TextField(
            controller: myController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(), 
              labelText: 'Secret'
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
          Divider(
            color: Colors.black,
            height: 36
          ),
          RaisedButton(
            child: Text('Send Mode'),
            onPressed: () async {
              if (await Nearby().checkLocationPermission()) {
                print('Location permissions granted :)');
              }else{
                await Nearby().askLocationPermission();
              }
              if (await Nearby().checkLocationEnabled()) {
                print('Location is ON :)');
              }else{
                await Nearby().enableLocationServices();
              }
              try {
                bool a = await Nearby().startAdvertising(
                  userName,
                  strategy,
                  onConnectionInitiated: onConnectionInit,
                  onConnectionResult: (id, status) {
                    showSnackbar(status);
                  },
                  onDisconnected: (id) {
                    showSnackbar("Disconnected: " + id);
                  },
                );
                showSnackbar("ADVERTISING: " + a.toString());
              } catch (exception) {
                showSnackbar(exception);
              }
            },
            color: Colors.lightBlue,
            textColor: Colors.white,
          ),
          RaisedButton(
              child: Text("Stop All Endpoints"),
              onPressed: () async {
                await Nearby().stopAllEndpoints();
              },
            ),
          Column(
            children: <Widget>[
              SizedBox(
                height: 320, // fixed height
                child: 
                ListView.builder(
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
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                if(prefs.getStringList("secret") != null){
                                    items = prefs.getStringList("secret");
                                }
                                items.add(arr[index]);
                                prefs.setStringList('secret', items);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                size: 20.0,
                                color: Colors.brown[900],
                              ),
                              onPressed: () async {
                                String a = arr[index];
                                showSnackbar("Sending $a to $cId");
                                Nearby().sendBytesPayload(cId, Uint8List.fromList(a.codeUnits));
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
        ]
      ),
      padding: EdgeInsets.all(25.0),
    );
  }
  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("id: " + id),
              Text("Token: " + info.authenticationToken),
              Text("Name" + info.endpointName),
              Text("Incoming: " + info.isIncomingConnection.toString()),
              RaisedButton(
                child: Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  cId = id;
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes);
                        showSnackbar(endid + ": " + str);
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status ==
                          PayloadStatus.IN_PROGRRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.FAILURE) {
                        print("failed");
                        showSnackbar(endid + ": FAILED to transfer file");
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.SUCCESS) {
                        showSnackbar(
                            "success, total bytes = ${payloadTransferUpdate.totalBytes}");

                        
                      }
                    },
                  );
                },
              ),
              RaisedButton(
                child: Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}