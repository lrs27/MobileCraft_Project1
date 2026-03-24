import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class LogMealScreen extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const LogMealScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final TextEditingController priceController = TextEditingController();
  bool saving = false;

  Future<void> saveMeal() async {
    final priceText = priceController.text.trim();

    if (priceText.isEmpty || double.tryParse(priceText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid price")),
      );
      return;
    }

    setState(() => saving = true);

    final db = await DatabaseHelper.instance.database;

    await db.insert('meal_logs', {
      'restaurantId': widget.restaurantId,
      'price': double.parse(priceText),
      'date': DateTime.now().toIso8601String(),
    });

    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Meal logged for ${widget.restaurantName}!")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Meal"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.restaurantName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "How much did you spend?",
                prefixText: "\$ ",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : saveMeal,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Meal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
