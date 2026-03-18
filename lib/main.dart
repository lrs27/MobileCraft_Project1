import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'restaurant_details.dart';

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
      home: RestaurantDetailsScreen(
        name: 'Campus Cafe',
        imageUrl: 'https://picsum.photos/600/300',
        price: '\$\$',
        distance: '0.4 mi',
        hours: '9:00 AM - 8:00 PM',
      ),
    );
  }
}
