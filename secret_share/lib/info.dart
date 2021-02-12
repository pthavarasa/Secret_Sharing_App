import 'package:flutter/material.dart';

class Info extends StatefulWidget {
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  int _activeMeterIndex;
  final Map<String, String> aboutApp = {
    'What is secret sharing?' : 'bla bla',
    'How to use it?' : 'bla bla',
  };
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount:  2,
          itemBuilder: (BuildContext context, int i) {
            return Card(
              margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
              child: ExpansionPanelList(
                expansionCallback: (int index, bool status) {
                  setState(() {
                    _activeMeterIndex = _activeMeterIndex == i ? null : i;
                  });
                },
                children: [
                  ExpansionPanel(
                    isExpanded: _activeMeterIndex == i,
                    headerBuilder: (BuildContext context, bool isExpanded) =>
                      Container(
                        padding: EdgeInsets.only(left: 15.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          aboutApp.keys.elementAt(i),
                          style: TextStyle(
                            fontSize: 16.0
                          ),
                        )
                      ),
                    body: Container(
                      padding: EdgeInsets.only(left: 20.0, bottom: 20.0),
                      alignment: Alignment.topLeft,
                      child: Text(aboutApp.values.elementAt(i)),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}