import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'add_review_screen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String price;
  final String distance;
  final String hours;
  final String description;

  const RestaurantDetailsScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.distance,
    required this.hours,
    required this.description,
  });

  Future<void> addToFavorites(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;

    // Find restaurant ID
    final result = await db.query(
      'restaurants',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant not found in database")),
      );
      return;
    }

    final restaurantId = result.first['id'];

    // Insert into favorites table
    await db.insert('favorites', {
      'restaurantId': restaurantId,
      'emoji': null,
      'note': null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to favorites")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ------------------ IMAGE ------------------
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.restaurant, size: 80),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ NAME + PRICE + DISTANCE ------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Text(distance),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 6),
                      Text("Hours: $hours"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),


            // ------------------ BUTTONS ------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  // Add to Favorites
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => addToFavorites(context),
                      icon: const Icon(Icons.favorite_border),
                      label: const Text("Add to Favorites"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Add Review
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReviewScreen(restaurantName: name),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text("Add Review"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Log Meal
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Log meal logic
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text("Log Meal"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
