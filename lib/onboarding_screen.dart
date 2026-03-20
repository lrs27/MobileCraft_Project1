import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController budgetController = TextEditingController();

  final List<String> cuisines = [
    'Pizza',
    'Chinese',
    'Mexican',
    'American',
    'Indian'
  ];

  List<String> selectedCuisines = [];

  void toggleCuisine(String cuisine) {
    setState(() {
      if (selectedCuisines.contains(cuisine)) {
        selectedCuisines.remove(cuisine);
      } else {
        selectedCuisines.add(cuisine);
      }
    });
  }

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CampusCrave"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Weekly Budget",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter budget",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Favorite Cuisines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: cuisines.map((cuisine) {
                final isSelected = selectedCuisines.contains(cuisine);
                return ChoiceChip(
                  label: Text(cuisine),
                  selected: isSelected,
                  onSelected: (_) => toggleCuisine(cuisine),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: goToHome,
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
