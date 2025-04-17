import 'package:flutter/material.dart';

// Define PlantType enum here if not defined in a separate models file
enum PlantType { flowers, herbs, trees }

extension PlantTypeExtension on PlantType {
  String get displayName {
    switch (this) {
      case PlantType.flowers:
        return 'Flowers';
      case PlantType.herbs:
        return 'Herbs';
      case PlantType.trees:
        return 'Trees';
    }
  }
}
// End enum definition

class QuizScreen extends StatelessWidget {
  final PlantType quizType;

  const QuizScreen({required this.quizType, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${quizType.displayName} Quiz'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              // Show different icons based on type (optional)
              quizType == PlantType.flowers
                  ? Icons.local_florist
                  : quizType == PlantType.herbs
                  ? Icons.grass
                  : Icons.park,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to the ${quizType.displayName} Quiz!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center, // Center align text
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement quiz starting logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Starting ${quizType.displayName} quiz... (Not implemented)',
                    ),
                  ),
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
