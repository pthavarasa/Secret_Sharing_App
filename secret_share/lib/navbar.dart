import 'package:flutter/material.dart';
import 'package:secret_share/receive.dart';
import 'package:secret_share/combine.dart';
import 'package:secret_share/split.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedNavIdex = 1;
  List<Widget> _widgetOptions = <Widget> [
    Receive(),
    Split(),
    Combine()
  ];
  void _onNavItemTap(int index){
    setState(() {
      _selectedNavIdex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Secret Sharing'))
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedNavIdex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Receive'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route_sharp),
            label: 'Split'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: 'Combine'
          )
        ],
        currentIndex: _selectedNavIdex,
        onTap: _onNavItemTap,
      )
    );
  }
}