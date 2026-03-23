import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database before app starts
  await DatabaseHelper.instance.database;

  runApp(const CampusCraveApp());
}

class CampusCraveApp extends StatelessWidget {
  const CampusCraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Crave',
      theme: ThemeData.dark(),
      home: const OnboardingScreen(),
    );
  }
}
