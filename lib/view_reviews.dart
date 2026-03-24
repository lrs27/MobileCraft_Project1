import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final String restaurantName;

  const ReviewsScreen({super.key, required this.restaurantName});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Map<String, dynamic>> reviews = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'reviews',
      where: 'restaurantName = ?',
      whereArgs: [widget.restaurantName],
      orderBy: 'id DESC',
    );

    setState(() {
      reviews = rows;
      loading = false;
    });
  }

  Future<void> deleteReview(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
    loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews for ${widget.restaurantName}"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? const Center(
                  child: Text(
                    "No reviews yet.",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final r = reviews[index];
                    final rating = r['rating'] ?? 0;

                    return Dismissible(
                      key: Key(r['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        deleteReview(r['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review deleted")),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            "⭐" * rating,
                            style: const TextStyle(fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              r['text'] ?? "No review text",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReviewScreen(
                restaurantName: widget.restaurantName,
              ),
            ),
          );
          loadReviews();
        },
        icon: const Icon(Icons.rate_review),
        label: const Text("Add Review"),
      ),
    );
  }
}
