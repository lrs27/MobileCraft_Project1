import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'home_screen.dart';

class AddEditRestaurantScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurant;

  const AddEditRestaurantScreen({super.key, this.restaurant});

  @override
  State<AddEditRestaurantScreen> createState() => _AddEditRestaurantScreenState();
}

class _AddEditRestaurantScreenState extends State<AddEditRestaurantScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cuisineController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.restaurant != null) {
      nameController.text = widget.restaurant!['name'] ?? '';
      cuisineController.text = widget.restaurant!['cuisine'] ?? '';
      priceController.text = (widget.restaurant!['priceLevel'] ?? 1).toString();
      hoursController.text = widget.restaurant!['hours'] ?? '';
    }
  }

  Future<void> saveRestaurant() async {
    final db = await DatabaseHelper.instance.database;

    final data = {
      'name': nameController.text,
      'cuisine': cuisineController.text,
      'priceLevel': int.tryParse(priceController.text) ?? 1,
      'hours': hoursController.text,
    };

    if (widget.restaurant == null) {
      await db.insert('restaurants', data);
    } else {
      await db.update(
        'restaurants',
        data,
        where: 'id = ?',
        whereArgs: [widget.restaurant!['id']],
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant == null ? "Add Restaurant" : "Edit Restaurant"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cuisineController,
              decoration: const InputDecoration(labelText: "Cuisine"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price Level (1-3)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: hoursController,
              decoration: const InputDecoration(labelText: "Hours"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveRestaurant,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
