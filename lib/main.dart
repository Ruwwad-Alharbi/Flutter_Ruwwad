import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyFranceDiariesApp());
}

class MyFranceDiariesApp extends StatelessWidget {
  const MyFranceDiariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My France Diaries',
      theme: ThemeData(primarySwatch: Colors.grey, fontFamily: 'Roboto'),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}