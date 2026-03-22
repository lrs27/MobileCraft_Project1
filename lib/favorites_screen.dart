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
