import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database/database_helper.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  TEMP FIX: Force delete old database
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'campus_crave.db'));

  // Recreate database
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
