// lib/widgets/quiz_body.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/screens/quizs/quiz_content.dart';
import 'package:local_plant_identification/screens/quizs/quiz_error_display.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';

class QuizBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Question> questions;
  final int currentIndex;
  final int? selectedAnswerIndex;
  final bool answered;
  final VoidCallback onRetry;
  final ValueChanged<int> onAnswerSelected;
  final VoidCallback showResultsCallback; // To handle end of quiz case

  const QuizBody({
    super.key,
    required this.isLoading,
    required this.error,
    required this.questions,
    required this.currentIndex,
    required this.selectedAnswerIndex,
    required this.answered,
    required this.onRetry,
    required this.onAnswerSelected,
    required this.showResultsCallback,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingIndicator();
    }

    if (error != null) {
      return Center(child: QuizErrorDisplay(error: error, onRetry: onRetry));
    }

    if (questions.isEmpty) {
      return const Center(
        child: Text(
          'No questions available.',
          style: TextStyle(color: Colors.black54), // Adjusted color
        ),
      );
    }

    // Ensure current index is valid before accessing questions
    if (currentIndex >= questions.length) {
      // This case should ideally be handled by the results dialog trigger,
      // but as a fallback, trigger it post-frame.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showResultsCallback(),
      );
      return const Center(
        child: Text(
          'Quiz finished. Showing results...',
          style: TextStyle(color: Colors.black54), // Adjusted color
        ),
      );
    }

    // If everything is okay, show the quiz content
    final currentQuestion = questions[currentIndex];
    return QuizContent(
      currentIndex: currentIndex,
      currentQuestion: currentQuestion,
      selectedAnswerIndex: selectedAnswerIndex,
      answered: answered,
      onAnswerSelected: onAnswerSelected,
    );
  }
}
