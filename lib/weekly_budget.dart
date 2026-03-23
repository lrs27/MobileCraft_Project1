import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class WeeklyBudgetScreen extends StatefulWidget {
  const WeeklyBudgetScreen({super.key});

  @override
  State<WeeklyBudgetScreen> createState() => _WeeklyBudgetScreenState();
}

class _WeeklyBudgetScreenState extends State<WeeklyBudgetScreen> {
  double weeklyBudget = 50.0; // Default weekly budget
  double totalSpent = 0.0;
  List<Map<String, dynamic>> weeklyMeals = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeeklyData();
  }

  Future<void> loadWeeklyData() async {
    final db = await DatabaseHelper.instance.database;

    // Get start of the week (Monday)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartString = weekStart.toIso8601String();

    // Query meals logged this week
    final meals = await db.rawQuery('''
      SELECT meal_logs.*, restaurants.name AS restaurantName
      FROM meal_logs
      JOIN restaurants ON meal_logs.restaurantId = restaurants.id
      WHERE meal_logs.date >= ?
      ORDER BY meal_logs.date DESC
    ''', [weekStartString]);

    double spent = 0.0;
    for (var m in meals) {
      spent += (m['price'] as num).toDouble();
    }

    setState(() {
      weeklyMeals = meals;
      totalSpent = spent;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double remaining = weeklyBudget - totalSpent;
    double progress = (totalSpent / weeklyBudget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Budget"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ------------------ BUDGET INPUT ------------------
                  const Text(
                    "Set Weekly Budget",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: weeklyBudget,
                          min: 20,
                          max: 200,
                          divisions: 18,
                          label: "\$${weeklyBudget.toStringAsFixed(0)}",
                          onChanged: (value) {
                            setState(() {
                              weeklyBudget = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        "\$${weeklyBudget.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ------------------ PROGRESS BAR ------------------
                  const Text(
                    "This Week's Spending",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade800,
                    color: progress >= 1 ? Colors.red : Colors.green,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Spent: \$${totalSpent.toStringAsFixed(2)} / \$${weeklyBudget.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  Text(
                    remaining >= 0
                        ? "Remaining: \$${remaining.toStringAsFixed(2)}"
                        : "Over budget by \$${remaining.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      color: remaining >= 0 ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------ MEAL LOG LIST ------------------
                  const Text(
                    "Meals Logged This Week",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  weeklyMeals.isEmpty
                      ? const Text(
                          "No meals logged yet.",
                          style: TextStyle(fontSize: 16),
                        )
                      : Column(
                          children: weeklyMeals.map((meal) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(meal['restaurantName']),
                                subtitle: Text(
                                  "Spent \$${meal['price']} on ${meal['date']}",
                                ),
                                trailing: const Icon(Icons.receipt_long),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
