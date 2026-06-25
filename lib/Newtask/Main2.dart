import 'package:flutter/material.dart';
import 'homePage.dart';

void main() {
  runApp(const Worldskills());
}

class Worldskills extends StatelessWidget {
  const Worldskills({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'newTask',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}