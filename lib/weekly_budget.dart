import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class WeeklyBudgetScreen extends StatefulWidget {
  const WeeklyBudgetScreen({super.key});

  @override
  State<WeeklyBudgetScreen> createState() => _WeeklyBudgetScreenState();
}

class _WeeklyBudgetScreenState extends State<WeeklyBudgetScreen> {
  double weeklyBudget = 0;
  double weeklySpent = 0;
  bool loading = true;

  List<Map<String, dynamic>> weeklyMeals = [];

  @override
  void initState() {
    super.initState();
    loadBudgetData();
  }

  Future<void> loadBudgetData() async {
    final db = await DatabaseHelper.instance.database;

    // Load weekly budget
    final settings = await db.query('settings', limit: 1);
    weeklyBudget = (settings.first['weeklyBudget'] as num).toDouble();

    // Load meals from last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7)).toIso8601String();

    final rows = await db.rawQuery('''
      SELECT meal_logs.price, meal_logs.date, restaurants.name
      FROM meal_logs
      JOIN restaurants ON meal_logs.restaurantId = restaurants.id
      WHERE meal_logs.date >= ?
      ORDER BY meal_logs.date DESC
    ''', [weekAgo]);

    double total = 0;
    for (final r in rows) {
      total += (r['price'] as num).toDouble();
    }

    setState(() {
      weeklySpent = total;
      weeklyMeals = rows;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = weeklyBudget - weeklySpent;

    final progress = weeklyBudget == 0
        ? 0.0
        : (weeklySpent / weeklyBudget).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Budget"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Budget: \$${weeklyBudget.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Spent: \$${weeklySpent.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Remaining: \$${remaining.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        color: remaining < 0 ? Colors.red : Colors.green,
                      ),
                    ),

                    const SizedBox(height: 20),

                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade800,
                      color: remaining < 0 ? Colors.red : Colors.green,
                      minHeight: 12,
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Meals Logged This Week (${weeklyMeals.length})",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (weeklyMeals.isEmpty)
                      const Text("No meals logged yet.")
                    else
                      ...weeklyMeals.map((meal) {
                        final price = (meal['price'] as num).toDouble();
                        final date = DateTime.parse(meal['date']);
                        final formattedDate =
                            "${date.month}/${date.day} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(meal['name']),
                          subtitle: Text("Logged on $formattedDate"),
                          trailing: Text(
                            "\$${price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}
