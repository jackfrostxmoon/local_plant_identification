import 'package:flutter/material.dart';

class QuizResultsDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onPlayAgain;
  final VoidCallback onClose;

  const QuizResultsDialog({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onPlayAgain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: const Text(
        'Quiz Finished!',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Your final score is $score out of $totalQuestions.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.lightBlueAccent, // Text color
          ),
          child: const Text('Play Again'),
          onPressed: onPlayAgain,
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey, // Text color
          ),
          child: const Text('Close'),
          onPressed: onClose,
        ),
      ],
    );
  }
}
