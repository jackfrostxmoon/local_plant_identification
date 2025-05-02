// Import all the necessary packages and files for the QuizContent widget.
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/screens/quizs/quiz_image.dart';
import 'package:local_plant_identification/screens/quizs/quiz_options_grid.dart';

// A widget that displays the content of a single quiz question.
class QuizContent extends StatelessWidget {
  final int currentIndex; // The index of the current question (0-based).
  final Question
      currentQuestion; // The Question object containing the question data.
  final int?
      selectedAnswerIndex; // The index of the answer selected by the user (nullable).
  final bool
      answered; // Flag indicating if the current question has been answered.
  final ValueChanged<int>
      onAnswerSelected; // Callback function when an answer option is selected.

  // Constructor for the QuizContent widget.
  const QuizContent({
    super.key,
    required this.currentIndex,
    required this.currentQuestion,
    required this.selectedAnswerIndex,
    required this.answered,
    required this.onAnswerSelected, // Renamed for clarity to match its purpose.
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(20.0), // Padding around the content for spacing.
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.start, // Align column content to the top.
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center column content horizontally.
        children: [
          // 1. Display the Question Text.
          Text(
            // Add the question number dynamically (currentIndex + 1).
            "${currentIndex + 1}. ${currentQuestion.questionText}",
            textAlign:
                TextAlign.center, // Center the question text horizontally.
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black, // Set text color to black.
                  fontWeight: FontWeight.bold, // Make the text bold.
                ),
          ),
          const SizedBox(height: 25), // Vertical space below the question text.

          // 2. Display the Image Area for the question.
          // The QuizImage widget handles loading and displaying the image.
          QuizImage(imageUrl: currentQuestion.imageUrl),
          const SizedBox(height: 30), // Vertical space below the image.

          // 3. Display the Options Grid for the answer choices.
          // The QuizOptionsGrid widget handles displaying the options and user interaction.
          QuizOptionsGrid(
            currentQuestion: currentQuestion, // Pass the current question data.
            selectedAnswerIndex:
                selectedAnswerIndex, // Pass the selected answer index.
            answered: answered, // Pass the answered status.
            onOptionSelected:
                onAnswerSelected, // Pass the callback to handle option selection.
          ),
          const SizedBox(
              height:
                  80), // Additional space at the bottom, useful if a FAB is present.
        ],
      ),
    );
  }
}
