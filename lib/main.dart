import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const DiceCrusherApp());
}

class DiceCrusherApp extends StatelessWidget {
  const DiceCrusherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Crusher',
      theme: ThemeData.dark(),
      home: const HomeScreen(),

    );
  }
}

