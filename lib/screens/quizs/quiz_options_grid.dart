// lib/widgets/quiz_options_grid.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/widgets/custom_quiz_option_button.dart'; // Import your button

class QuizOptionsGrid extends StatelessWidget {
  final Question currentQuestion;
  final int? selectedAnswerIndex;
  final bool answered;
  final ValueChanged<int> onOptionSelected; // Callback

  const QuizOptionsGrid({
    super.key,
    required this.currentQuestion,
    required this.selectedAnswerIndex,
    required this.answered,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, // 2 columns
      shrinkWrap: true, // Important inside SingleChildScrollView/Column
      physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
      mainAxisSpacing: 15.0, // Spacing between rows
      crossAxisSpacing: 15.0, // Spacing between columns
      childAspectRatio: 2.5, // Adjust aspect ratio (Width / Height)
      children: List.generate(currentQuestion.options.length, (index) {
        // Ensure we don't generate more buttons than options available
        // This check might be redundant if Question model ensures options exist
        if (index >= currentQuestion.options.length) {
          return const SizedBox.shrink(); // Return empty widget if out of bounds
        }

        return QuizOptionButton(
          optionIndex: index,
          optionText: currentQuestion.options[index],
          currentQuestion: currentQuestion,
          selectedAnswerIndex: selectedAnswerIndex,
          answered: answered,
          onPressed: () => onOptionSelected(index), // Use the callback
        );
      }),
    );
  }
}
