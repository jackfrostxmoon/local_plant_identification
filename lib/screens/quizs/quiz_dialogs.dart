// screens/quizs/quiz_dialogs.dart (Assuming file name)
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class QuizResultsDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onPlayAgain;
  final VoidCallback onClose; // Keep onClose if needed for just closing dialog

  const QuizResultsDialog({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onPlayAgain,
    required this.onClose, // Keep if needed
  });

  @override
  Widget build(BuildContext context) {
    // Get l10n instance
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: const Color(0xFFA8E6A2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text(
        l10n.quizDialogTitle, // Localized
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Text(
        // Use localized string with placeholders
        l10n.quizDialogContent(score, totalQuestions),
        style: const TextStyle(color: Colors.black),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          onPressed: onPlayAgain,
          child: Text(
            l10n.quizDialogPlayAgain, // Localized
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          // Option 1: Just close the dialog
          //onPressed: onClose,
          // Option 2: Close dialog AND navigate to dashboard (choose one)
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pushAndRemoveUntil(
              // Go to dashboard, remove quiz screen
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          },
          child: Text(l10n.quizDialogClose), // Localized
        ),
      ],
    );
  }
}
