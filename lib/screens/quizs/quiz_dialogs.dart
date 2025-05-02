// screens/quizs/quiz_dialogs.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

// A dialog widget to display the quiz results.
class QuizResultsDialog extends StatelessWidget {
  final int score; // The final score achieved by the user.
  final int totalQuestions; // The total number of questions in the quiz.
  final VoidCallback
      onPlayAgain; // Callback function for the "Play Again" button.
  final VoidCallback
      onClose; // Callback function for the "Close" button (kept for flexibility).

  // Constructor for the QuizResultsDialog.
  const QuizResultsDialog({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onPlayAgain,
    required this.onClose, // Kept for flexibility, though currently navigates.
  });

  @override
  Widget build(BuildContext context) {
    // Get the AppLocalizations instance for localized strings.
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor:
          const Color(0xFFA8E6A2), // Custom background color for the dialog.
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15.0)), // Rounded corners for the dialog.
      title: Text(
        l10n.quizDialogTitle, // Localized title for the results dialog.
        style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold), // Title text style.
      ),
      content: Text(
        // Use a localized string for the content, inserting the score and total questions.
        l10n.quizDialogContent(score, totalQuestions),
        style: const TextStyle(color: Colors.black), // Content text style.
      ),
      actions: <Widget>[
        // Button to play the quiz again.
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.black), // Text color for the button.
          onPressed:
              onPlayAgain, // Execute the onPlayAgain callback when pressed.
          child: Text(
            l10n.quizDialogPlayAgain, // Localized text for the "Play Again" button.
            style: const TextStyle(
                fontWeight: FontWeight.bold), // Button text style.
          ),
        ),
        // Button to close the dialog and navigate to the dashboard.
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.red), // Text color for the button.
          onPressed: () {
            Navigator.of(context).pop(); // Close the current dialog.
            // Navigate to the DashboardScreen and remove all previous routes from the stack.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      const DashboardScreen()), // Build the DashboardScreen route.
              (Route<dynamic> route) =>
                  false, // Condition to remove all previous routes.
            );
          },
          child: Text(
              l10n.quizDialogClose), // Localized text for the "Close" button.
        ),
      ],
    );
  }
}
