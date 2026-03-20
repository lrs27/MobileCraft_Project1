import 'add_edit_restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'restaurant_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> filteredRestaurants = [];

  bool isLoading = true;

  // Filters
  String searchQuery = "";
  String selectedCuisine = "All";
  int selectedPrice = 0; // 0 = All
  bool openNow = false;

  final List<String> cuisines = [
    "All",
    "American",
    "Mexican",
    "Italian",
    "Asian",
    "Cafe",
    "Mediterranean",
  ];

  @override
  void initState() {
    super.initState();
    loadRestaurants();
  }

  Future<void> loadRestaurants() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('restaurants');

    setState(() {
      restaurants = data;
      filteredRestaurants = data;
      isLoading = false;
    });
  }

  void applyFilters() {
    List<Map<String, dynamic>> results = restaurants;

    // Search filter
    if (searchQuery.isNotEmpty) {
      results = results
          .where((r) =>
              r['name'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Cuisine filter
    if (selectedCuisine != "All") {
      results = results
          .where((r) => r['cuisine'] == selectedCuisine)
          .toList();
    }

    // Price filter
    if (selectedPrice != 0) {
      results = results
          .where((r) => r['priceLevel'] == selectedPrice)
          .toList();
    }

    // Open Now filter (simple placeholder logic)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Crave"),
        centerTitle: true,
      ),

      body: Column(
        children: [

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
                // Cuisine filter
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

                // Price filter
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

                // Open Now filter
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
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantDetailsScreen(
                                      name: r['name'],
                                      imageUrl: r['imageUrl'] ?? '',
                                      price: "\$" * (r['priceLevel'] ?? 1),
                                      distance:
                                          "${r['distance'] ?? 0.0} mi",
                                      hours: r['hours'] ?? "N/A",
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

      // ---------------- FLOATING BUTTON ----------------
     floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditRestaurantScreen(),
      ),
    );

    if (result == true) {
      loadRestaurants();
    }
  },
  icon: const Icon(Icons.add),
  label: const Text("Add Restaurant"),
      ),
    );
  }
}
