import 'package:flutter/material.dart';
// Adjust package name as needed
import 'package:local_plant_identification/screens/quizs/quiz_screen.dart';

class QuizTypeButton extends StatelessWidget {
  final PlantType plantType;

  const QuizTypeButton({required this.plantType, super.key});

  // Function to handle navigation
  void _navigateToQuiz(BuildContext context, PlantType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(quizType: type)),
    );
    print('Navigating to ${type.displayName} quiz...');
  }

  @override
  Widget build(BuildContext context) {
    final String label = plantType.displayName; // Get label from enum

    return Padding(
      // Add vertical spacing between buttons
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.white, // Background of the row
        borderRadius: BorderRadius.circular(25.0), // Match outer roundness
        child: InkWell(
          onTap: () => _navigateToQuiz(context, plantType), // Navigate on tap
          borderRadius: BorderRadius.circular(25.0), // Splash effect shape
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0), // Outer shape
              border: Border.all(
                color: Colors.black, // Black border
                width: 1.5, // Border thickness
              ),
            ),
            child: Row(
              children: [
                // Plant type label (takes available space)
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Slightly bold
                      color: Colors.black,
                    ),
                  ),
                ),
                // Small "Button" on the right
              ],
            ),
          ),
        ),
      ),
    );
  }
}
