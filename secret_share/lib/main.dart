import 'package:flutter/material.dart';
import 'package:secret_share/navbar.dart';
import 'package:secret_share/splashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Bar', 
      theme: ThemeData(
        primaryColor: Colors.blue, 
        accentColor: Colors.blueAccent
      ),
      home: SplashScreen(),
      routes: {
        '/home': (BuildContext context) => Navbar()
      },
    );
  }
}