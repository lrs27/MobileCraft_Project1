import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'add_edit_restauraunt_screen.dart';
import 'restaurant_details.dart';
import 'favorites_screen.dart';
import 'weekly_budget.dart';
import 'ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> filteredRestaurants = [];

  double weeklyBudget = 0.0;
  double weeklySpent = 0.0;

  bool isLoading = true;

  // Filters
  String searchQuery = "";
  String selectedCuisine = "All";
  int selectedPrice = 0;
  bool openNow = false;

  final List<String> cuisines = [
    'All',
    'Pizza',
    'Chinese',
    'Mexican',
    'American',
    'Indian',
    'Cafe',
  ];

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await loadRestaurants();
  }


  // ------------------ LOAD RESTAURANTS ------------------
  Future<void> loadRestaurants() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('restaurants');

    setState(() {
      restaurants = data;
      filteredRestaurants = data;
      isLoading = false;
    });
  }

  // ------------------ APPLY FILTERS ------------------
  void applyFilters() {
    List<Map<String, dynamic>> results = restaurants;

    if (searchQuery.isNotEmpty) {
      results = results
          .where((r) =>
              r['name'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (selectedCuisine != "All") {
      results = results.where((r) => r['cuisine'] == selectedCuisine).toList();
    }

    if (selectedPrice != 0) {
      results = results.where((r) => r['priceLevel'] == selectedPrice).toList();
    }

    if (openNow) {
      results = results
          .where((r) => (r['hours'] ?? "").contains("AM"))
          .toList();
    }

    setState(() {
      filteredRestaurants = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    double remaining = weeklyBudget - weeklySpent;
    double progress = weeklyBudget == 0
        ? 0
        : (weeklySpent / weeklyBudget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Crave"),
        centerTitle: true,
        actions: [
          // FAVORITES BUTTON
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),

          // WEEKLY BUDGET BUTTON
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeeklyBudgetScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // ---------------- WEEKLY BUDGET CARD ----------------
          if (weeklyBudget > 0)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Budget",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade800,
                    color: progress >= 1 ? Colors.red : Colors.green,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Spent: \$${weeklySpent.toStringAsFixed(2)} / \$${weeklyBudget.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    remaining >= 0
                        ? "Remaining: \$${remaining.toStringAsFixed(2)}"
                        : "Over budget by \$${remaining.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: remaining >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search restaurants...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                searchQuery = value;
                applyFilters();
              },
            ),
          ),

          // ---------------- FILTER CHIPS ----------------
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                DropdownButton<String>(
                  value: selectedCuisine,
                  dropdownColor: Colors.black,
                  items: cuisines
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedCuisine = value!;
                    applyFilters();
                  },
                ),
                const SizedBox(width: 12),

                FilterChip(
                  label: const Text("\$"),
                  selected: selectedPrice == 1,
                  onSelected: (_) {
                    selectedPrice = selectedPrice == 1 ? 0 : 1;
                    applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                FilterChip(
                  label: const Text("\$\$"),
                  selected: selectedPrice == 2,
                  onSelected: (_) {
                    selectedPrice = selectedPrice == 2 ? 0 : 2;
                    applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                FilterChip(
                  label: const Text("\$\$\$"),
                  selected: selectedPrice == 3,
                  onSelected: (_) {
                    selectedPrice = selectedPrice == 3 ? 0 : 3;
                    applyFilters();
                  },
                ),
                const SizedBox(width: 12),

                FilterChip(
                  label: const Text("Open Now"),
                  selected: openNow,
                  onSelected: (value) {
                    openNow = value;
                    applyFilters();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ---------------- RESTAURANT LIST ----------------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRestaurants.isEmpty
                    ? const Center(
                        child: Text(
                          "No restaurants match your filters.",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final r = filteredRestaurants[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  r['image'] ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
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

                              //  Add Review Button + Arrow
                              trailing:const Icon(Icons.chevron_right),
                                

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantDetailsScreen(
                                      name: r['name'],
                                      image: r['image'] ?? '',
                                      price: "\$" * (r['priceLevel'] ?? 1),
                                      distance: "${r['distance'] ?? 0.0} mi",
                                      hours: r['hours'] ?? "N/A",
                                      description: r['description'] ?? "No description available.",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      // ---------------- FLOATING BUTTONS ----------------
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          FloatingActionButton(
            heroTag: "ai_button",
            backgroundColor: Colors.deepPurple,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MealMatcherScreen()),
              );
            },
            child: const Icon(Icons.auto_awesome),
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            heroTag: "add_restaurant_button",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditRestaurantScreen(),
                ),
              );

              if (result == true) {
                loadAllData();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Restaurant"),
          ),
        ],
      ),
    );
  }
}
