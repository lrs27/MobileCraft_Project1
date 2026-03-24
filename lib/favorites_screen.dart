import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'restaurant_details.dart';

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

  // ⭐ Remove favorite + show UNDO
  Future<bool> _removeFavoriteWithUndo(int restaurantId) async {
    final db = await DatabaseHelper.instance.database;

    // Remove from favorites
    await db.delete(
      'favorites',
      where: 'restaurantId = ?',
      whereArgs: [restaurantId],
    );

    // Refresh UI
    await loadFavorites();

    // Snackbar with UNDO
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Removed from favorites"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () async {
            await db.insert('favorites', {
              'restaurantId': restaurantId,
              'emoji': null,
              'note': null,
            });
            await loadFavorites();
          },
        ),
      ),
    );

    return true;
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

                    return Dismissible(
                      key: ValueKey(r['id']),
                      direction: DismissDirection.endToStart,

                      // Red delete background
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      // Handle delete + undo
                      confirmDismiss: (_) async {
                        return await _removeFavoriteWithUndo(r['id']);
                      },

                      child: Card(
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

                          // ⭐ TAP → Go to Restaurant Details
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailsScreen(
                                  name: r['name'],
                                  imageUrl: r['imageUrl'] ?? '',
                                  price: "\$" * (r['priceLevel'] ?? 1),
                                  distance: "${r['distance'] ?? 0.0} mi",
                                  hours: r['hours'] ?? "N/A",
                                  description:
                                      r['description'] ?? "No description available",
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
