import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'add_edit_restauraunt_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final db = await DatabaseHelper.instance.database;

    final data = await db.rawQuery('''
      SELECT restaurants.*
      FROM favorites
      JOIN restaurants ON favorites.restaurantId = restaurants.id
    ''');

    setState(() {
      favorites = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(
                  child: Text(
                    "No favorites yet.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final r = favorites[index];

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
                        subtitle: Text(r['cuisine']),
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditRestaurantScreen(),
            ),
          );

          if (result == true) {
            loadFavorites();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Restaurant"),
      ),
    );
  }
}
