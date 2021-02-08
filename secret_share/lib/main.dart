import 'package:flutter/material.dart';
import 'package:secret_share/navbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Bar', 
      home: Navbar()
    );
  }
}