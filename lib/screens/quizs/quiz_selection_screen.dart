import 'package:flutter/material.dart';
// Adjust package name as needed
import 'package:local_plant_identification/screens/quizs/quiz_type_button.dart';
import 'package:local_plant_identification/screens/quizs/quiz_type_header.dart';
// Import your PlantType enum if needed
import 'package:local_plant_identification/screens/quizs/quiz_screen.dart'; // For PlantType enum

class QuizSelectionScreen extends StatelessWidget {
  const QuizSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align header left
          children: const [
            // Add the header
            QuizTypeHeader(),

            // Add the buttons
            QuizTypeButton(plantType: PlantType.flowers),
            QuizTypeButton(plantType: PlantType.herbs),
            QuizTypeButton(plantType: PlantType.trees),

            // Add Spacer if you want to push buttons to the top
            // Spacer(),
          ],
        ),
      ),
    );
  }
}
