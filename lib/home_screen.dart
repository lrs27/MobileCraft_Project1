import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dice Breaker',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/game'),
                child: const Text('Start'),
              ),
              
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Exit App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}