import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:device_info/device_info.dart';

class Connection{
  BuildContext context;
  String cId = "0";
  Function(String) onReceivedString;
  String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_STAR;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool isStartAdvertising = false;
  bool isStartDiscovering = false;

  Connection({
    this.cId,
    this.context,
    this.onReceivedString
  }){
    initUserName();
  }

  Future<void> initUserName() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    userName = androidInfo.manufacturer + androidInfo.model;
  }

  void setContext(BuildContext context){
    this.context = context;
  }

  void receivedString(Function(String) onCountChange){
    this.onReceivedString = onCountChange;
  }

  String get getCid{
    return cId;
  }

  void showSnackbar(dynamic a) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(a.toString()),
      ));
  }

  void permissionsHandling() async {
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
  }

  void stopAdvertising() async {
    if(!isStartAdvertising)
      await Nearby().stopAdvertising();
    //isStartAdvertising = false;
  }

  void stopDiscovery() async {
    if(!isStartDiscovering)
      await Nearby().stopDiscovery();
    //isStartDiscovering = false;
  }

  void stopAllEndpoints() async {
    if(isStartDiscovering || isStartAdvertising)
      await Nearby().stopAllEndpoints();
    isStartDiscovering = isStartAdvertising = false;
  }

  void sendString(String str) async {
    showSnackbar("Sending $str to $cId");
    Nearby().sendBytesPayload(cId, Uint8List.fromList(str.codeUnits));
  }

  void startAdvertising() async {
    isStartAdvertising = true;
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
  }

  void startDiscovering() async {
    isStartDiscovering = true;
    try {
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // show sheet automatically to request connection
          showModalBottomSheet(
            context: context,
            builder: (builder) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("id: " + id),
                    Text("Name: " + name),
                    Text("ServiceId: " + serviceId),
                    RaisedButton(
                      child: Text("Request Connection"),
                      onPressed: () {
                        Navigator.pop(context);
                        Nearby().requestConnection(
                          userName,
                          id,
                          onConnectionInitiated: (id, info) {
                            onConnectionInit(id, info);
                          },
                          onConnectionResult: (id, status) {
                            showSnackbar(status);
                          },
                          onDisconnected: (id) {
                            showSnackbar(id);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        onEndpointLost: (id) {
          showSnackbar("Lost Endpoint:" + id);
        },
      );
      showSnackbar("DISCOVERING: " + a.toString());
    } catch (e) {
      showSnackbar(e);
    }
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
                        onReceivedString(str);
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
  Widget connectionAboutDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('About Make Connection !'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: TextSpan(
              text: 'bla bla bla bla bla bla blaaaaa',
              style: const TextStyle(color: Colors.black87),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Okay, got it!'),
        ),
      ],
    );
  }
}