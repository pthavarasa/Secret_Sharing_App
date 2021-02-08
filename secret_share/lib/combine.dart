import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Combine extends StatefulWidget {
  @override
  _CombineState createState() => _CombineState();
}

class _CombineState extends State<Combine> {
  List<String> items = List<String>();
  final myController = TextEditingController();

  @override
  void initState(){
    getData();
  }

  void shareCombine(){
    SSS sss = new SSS();
    setState(() {
      myController.text = sss.combine(items, true);
    });
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getStringList("secret") != null){
      setState(() {
        items = prefs.getStringList("secret");
      });
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
    return Scaffold(
      body: Column(
        children: [
          RaisedButton(
            child: Text('Peer Device'),
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
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    onLongPress: (){},
                    title: Text(items[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 20.0,
                            color: Colors.brown[900],
                          ),
                          onPressed: () {},
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
          TextField(
            controller: myController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(), 
              labelText: 'Secret'
            )
          ),
        ]
      )
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
                        setState(() {
                          items.add(str);
                        });
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