import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/widgets/custom_quiz_option_button.dart'; // Import your custom button widget.

// A widget that displays the answer options for a quiz question in a grid format.
class QuizOptionsGrid extends StatelessWidget {
  final Question
      currentQuestion; // The Question object containing the question data and options.
  final int?
      selectedAnswerIndex; // The index of the answer selected by the user (nullable).
  final bool
      answered; // Flag indicating if the current question has been answered.
  final ValueChanged<int>
      onOptionSelected; // Callback when an answer option is selected.

  // Constructor for the QuizOptionsGrid widget.
  const QuizOptionsGrid({
    super.key,
    required this.currentQuestion,
    required this.selectedAnswerIndex,
    required this.answered,
    required this.onOptionSelected, // Callback
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, // Arrange options in 2 columns.
      shrinkWrap:
          true, // Important when used inside a SingleChildScrollView or Column to size the grid based on its children.
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling within the grid itself.
      mainAxisSpacing: 15.0, // Vertical spacing between grid rows.
      crossAxisSpacing: 15.0, // Horizontal spacing between grid columns.
      childAspectRatio:
          2.5, // Set the aspect ratio (width / height) for each grid item. Adjust as needed.
      children: List.generate(currentQuestion.options.length, (index) {
        // Generate a list of widgets for each option in the current question.
        // This check ensures we don't try to generate more buttons than there are options,
        // though the Question model should ideally ensure options are available.
        if (index >= currentQuestion.options.length) {
          return const SizedBox
              .shrink(); // Return an empty widget if the index is out of bounds.
        }

        // Create a CustomQuizOptionButton for each answer option.
        return QuizOptionButton(
          optionIndex: index, // The index of the current option.
          optionText: currentQuestion.options[
              index], // The text of the current option (already localized).
          currentQuestion:
              currentQuestion, // Pass the entire question object (needed for correct answer index).
          selectedAnswerIndex:
              selectedAnswerIndex, // Pass the index of the selected answer.
          answered: answered, // Pass whether the question has been answered.
          onPressed: () => onOptionSelected(
              index), // Execute the callback with the option index when pressed.
        );
      }),
    );
  }
}
