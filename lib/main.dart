import 'package:flutter/material.dart';
import 'package:lppl_93fm_suara_madiun/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Radio Suara Madiun",
      home: Scaffold(
        body: HomePlayer(),
      ),
    );
  }
}
