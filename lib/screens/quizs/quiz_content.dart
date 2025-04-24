// lib/widgets/quiz_content.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/quiz_image.dart';
import 'package:local_plant_identification/screens/quizs/quiz_options_grid.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';

class QuizContent extends StatelessWidget {
  final int currentIndex;
  final Question currentQuestion;
  final int? selectedAnswerIndex;
  final bool answered;
  final ValueChanged<int> onAnswerSelected; // Renamed for clarity

  const QuizContent({
    super.key,
    required this.currentIndex,
    required this.currentQuestion,
    required this.selectedAnswerIndex,
    required this.answered,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align top
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Question Text
          Text(
            // Add question number dynamically
            "${currentIndex + 1}. ${currentQuestion.questionText}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black, // black text
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // 2. Image Area
          QuizImage(imageUrl: currentQuestion.imageUrl),
          const SizedBox(height: 30),

          // 3. Options Grid
          QuizOptionsGrid(
            currentQuestion: currentQuestion,
            selectedAnswerIndex: selectedAnswerIndex,
            answered: answered,
            onOptionSelected: onAnswerSelected, // Pass the callback down
          ),
          const SizedBox(height: 80), // Space for the FAB if it's shown
        ],
      ),
    );
  }
}
