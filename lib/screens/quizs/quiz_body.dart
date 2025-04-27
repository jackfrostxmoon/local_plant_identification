// lib/widgets/quiz_body.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/screens/quizs/quiz_content.dart';
import 'package:local_plant_identification/screens/quizs/quiz_error_display.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class QuizBody extends StatelessWidget {
  final bool isLoading;
  final String? error; // Error message is already localized by the parent
  final List<Question>
      questions; // Questions are already localized by the model
  final int currentIndex;
  final int? selectedAnswerIndex;
  final bool answered;
  final VoidCallback onRetry;
  final ValueChanged<int> onAnswerSelected;
  final VoidCallback showResultsCallback;

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
    // Get l10n instance for static messages
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const LoadingIndicator();
    }

    if (error != null) {
      // Pass the already localized error message
      return Center(child: QuizErrorDisplay(error: error!, onRetry: onRetry));
    }

    if (questions.isEmpty) {
      return Center(
        child: Text(
          l10n.quizBodyNoQuestions, // Localized
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    if (currentIndex >= questions.length) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showResultsCallback(),
      );
      return Center(
        child: Text(
          l10n.quizBodyFinished, // Localized
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    // Pass the already localized question data
    final currentQuestion = questions[currentIndex];
    return QuizContent(
      currentIndex: currentIndex,
      currentQuestion: currentQuestion, // Contains localized text/options
      selectedAnswerIndex: selectedAnswerIndex,
      answered: answered,
      onAnswerSelected: onAnswerSelected,
    );
  }
}
