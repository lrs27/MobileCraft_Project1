import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'restaurant_details.dart';

class MealMatcherScreen extends StatefulWidget {
  const MealMatcherScreen({super.key});

  @override
  State<MealMatcherScreen> createState() => _MealMatcherScreenState();
}

class _MealMatcherScreenState extends State<MealMatcherScreen> {
  String? selectedMood;
  String? selectedTime;
  String? selectedBudget;

  List<Map<String, dynamic>> results = [];
  bool loading = false;

  final List<String> moods = [
    "Tired",
    "Stressed",
    "Happy",
    "In a rush",
    "Hungry AF",
    "Broke",
  ];

  final List<String> timeOptions = [
    "10 min",
    "20 min",
    "30+ min",
  ];

  final List<String> budgetOptions = [
    "Cheap",
    "Normal",
    "Treat myself",
  ];

  // ---------------- MOOD → CUISINE MAPPING ----------------
  List<String> cuisinesForMood(String mood) {
    switch (mood) {
      case "Tired":
        return ["Cafe", "American"];
      case "Stressed":
        return ["Asian", "Chinese"];
      case "Happy":
        return ["Pizza", "Mexican"];
      case "In a rush":
        return ["American", "Fast Food", "Pizza"];
      case "Hungry AF":
        return ["American", "Mexican", "Pizza"];
      case "Broke":
        return ["Pizza", "Chinese", "Cafe"];
      default:
        return [];
    }
  }

  // ---------------- BUDGET → PRICE LEVEL ----------------
  int priceForBudget(String budget) {
    switch (budget) {
      case "Cheap":
        return 1;
      case "Normal":
        return 2;
      case "Treat myself":
        return 3;
      default:
        return 3;
    }
  }

  // ---------------- TIME → MAX DISTANCE ----------------
  double distanceForTime(String time) {
    switch (time) {
      case "10 min":
        return 0.2;
      case "20 min":
        return 0.5;
      case "30+ min":
        return 1.0;
      default:
        return 1.0;
    }
  }

  // ---------------- RUN MATCHING LOGIC ----------------
  Future<void> matchRestaurants() async {
    if (selectedMood == null || selectedTime == null || selectedBudget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all options")),
      );
      return;
    }

    setState(() => loading = true);

    final db = await DatabaseHelper.instance.database;
    final allRestaurants = await db.query('restaurants');

    final allowedCuisines = cuisinesForMood(selectedMood!);
    final maxPrice = priceForBudget(selectedBudget!);
    final maxDistance = distanceForTime(selectedTime!);

    final filtered = allRestaurants.where((r) {
      final cuisineMatch = allowedCuisines.contains(r['cuisine']);
      final priceMatch = (r['priceLevel'] as int) <= maxPrice;
      final distanceMatch = (r['distance'] as num).toDouble() <= maxDistance;

      return cuisineMatch && priceMatch && distanceMatch;
    }).toList();

    setState(() {
      results = filtered;
      loading = false;
    });
  }

  // ---------------- CHIP BUILDER ----------------
  Widget buildChipGroup({
    required String title,
    required List<String> options,
    required String? selected,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: options.map((o) {
            final isSelected = selected == o;
            return ChoiceChip(
              label: Text(o),
              selected: isSelected,
              selectedColor: Colors.deepPurple,
              onSelected: (_) => onSelect(o),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Meal Matcher"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // MOOD
            buildChipGroup(
              title: "How are you feeling?",
              options: moods,
              selected: selectedMood,
              onSelect: (v) => setState(() => selectedMood = v),
            ),

            // TIME
            buildChipGroup(
              title: "How much time do you have?",
              options: timeOptions,
              selected: selectedTime,
              onSelect: (v) => setState(() => selectedTime = v),
            ),

            // BUDGET
            buildChipGroup(
              title: "What's your budget vibe?",
              options: budgetOptions,
              selected: selectedBudget,
              onSelect: (v) => setState(() => selectedBudget = v),
            ),

            // MATCH BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: matchRestaurants,
                child: const Text("Match Me"),
              ),
            ),

            const SizedBox(height: 30),

            // RESULTS
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (results.isEmpty)
              const Center(
                child: Text(
                  "No matches found. Try adjusting your mood or time.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Matches",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ...results.map((r) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            r['imageUrl'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.restaurant),
                            ),
                          ),
                        ),
                        title: Text(r['name']),
                        subtitle: Text(
                          "${r['cuisine']} • ${"\$" * (r['priceLevel'] ?? 1)}",
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailsScreen(
                                name: r['name'],
                                imageUrl: r['imageUrl'] ?? '',
                                price: "\$" * (r['priceLevel'] ?? 1),
                                distance: "${r['distance']} mi",
                                hours: r['hours'] ?? "N/A",
                                description: r['description'] ?? "No description available.",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
