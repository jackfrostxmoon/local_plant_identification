// lib/widgets/quiz_error_display.dart
import 'package:flutter/material.dart';

class QuizErrorDisplay extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const QuizErrorDisplay({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
          const SizedBox(height: 10),
          Text(
            'Error: ${error ?? "An unknown error occurred."}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87), // Adjusted color
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
