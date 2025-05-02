//Import all the necessary packages and files
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/screens/quizs/quiz_content.dart';
import 'package:local_plant_identification/screens/quizs/quiz_error_display.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

// The main body of the quiz screen, responsible for displaying content based on the quiz state.
class QuizBody extends StatelessWidget {
  final bool isLoading; // Flag to indicate if content is loading.
  final String?
      error; // Error message to display if something goes wrong (already localized by the parent).
  final List<Question>
      questions; // List of quiz questions (assumed to be localized by the Question model).
  final int
      currentIndex; // The index of the question currently being displayed.
  final int?
      selectedAnswerIndex; // The index of the answer selected by the user for the current question.
  final bool
      answered; // Flag to indicate if the current question has been answered.
  final VoidCallback
      onRetry; // Callback function to retry fetching questions on error.
  final ValueChanged<int>
      onAnswerSelected; // Callback function when an answer is selected.
  final VoidCallback
      showResultsCallback; // Callback function to display the quiz results.

  // Constructor for the QuizBody widget.
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
    // Get the AppLocalizations instance for static localized messages.
    final l10n = AppLocalizations.of(context)!;

    // Display a loading indicator if the content is still loading.
    if (isLoading) {
      return const LoadingIndicator();
    }

    // Display an error message and a retry button if an error occurred.
    // The error message itself is already localized by the parent widget.
    if (error != null) {
      // Pass the already localized error message to the error display widget.
      return Center(child: QuizErrorDisplay(error: error!, onRetry: onRetry));
    }

    // Display a message if no questions were loaded or found.
    if (questions.isEmpty) {
      return Center(
        child: Text(
          l10n.quizBodyNoQuestions, // Localized message for no questions.
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    // If the current index is beyond the number of questions, trigger the show results callback.
    // This handles the transition to the results screen when the quiz is finished.
    if (currentIndex >= questions.length) {
      // Schedule the callback to be executed after the current frame is built.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showResultsCallback(),
      );
      // Display a message indicating the quiz is finished while the results dialog is shown.
      return Center(
        child: Text(
          l10n.quizBodyFinished, // Localized message for quiz finished.
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    // If there are questions and the quiz is not finished, display the current question content.
    // Get the current question data (which includes localized text and options).
    final currentQuestion = questions[currentIndex];
    // Display the QuizContent widget, passing all necessary data and callbacks.
    return QuizContent(
      currentIndex: currentIndex, // The index of the current question.
      currentQuestion:
          currentQuestion, // The current question object (already localized).
      selectedAnswerIndex:
          selectedAnswerIndex, // The index of the selected answer.
      answered: answered, // Whether the current question has been answered.
      onAnswerSelected:
          onAnswerSelected, // The callback for when an answer is selected.
    );
  }
}
