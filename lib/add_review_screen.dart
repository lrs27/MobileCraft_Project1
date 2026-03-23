import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class AddReviewScreen extends StatefulWidget {
  final String restaurantName;

  const AddReviewScreen({super.key, required this.restaurantName});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController reviewController = TextEditingController();
  int rating = 3;

  Future<void> saveReview() async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('reviews', {
      'restaurantName': widget.restaurantName,
      'rating': rating,
      'text': reviewController.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Rate from 1 to 5",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            DropdownButton<int>(
              value: rating,
              items: List.generate(5, (index) {
                int value = index + 1;
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  rating = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                labelText: "Write a short review",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveReview,
                child: const Text("Save Review"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
