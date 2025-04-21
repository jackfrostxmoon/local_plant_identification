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
      backgroundColor: const Color(0xFFA8E6A2), // Dark background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: const Text(
        'Quiz Finished!',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Your final score is $score out of $totalQuestions.',
        style: const TextStyle(color: Colors.black),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.purple, // Text color
          ),
          onPressed: onPlayAgain,
          child: const Text('Play Again'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, // Text color
          ),
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
