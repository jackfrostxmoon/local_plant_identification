import 'package:flutter/material.dart';

// A widget to display an error message and a retry button in the quiz screen.
class QuizErrorDisplay extends StatelessWidget {
  final String? error; // The error message to display (can be null).
  final VoidCallback
      onRetry; // Callback function to be executed when the retry button is pressed.

  // Constructor for the QuizErrorDisplay widget.
  const QuizErrorDisplay({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the content.
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Vertically center the column's children.
        children: [
          // Display an error icon.
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
          const SizedBox(height: 10), // Vertical space.
          // Display the error message.
          Text(
            // Use the provided error message, or a default if error is null.
            'Error: ${error ?? "An unknown error occurred."}',
            textAlign: TextAlign.center, // Center the text horizontally.
            style:
                const TextStyle(color: Colors.black87), // Adjusted text color.
          ),
          const SizedBox(height: 20), // Vertical space.
          // Display the retry button.
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.blueAccent.shade700, // Background color of the button.
              foregroundColor: Colors.white, // Text color of the button.
            ),
            onPressed:
                onRetry, // Execute the onRetry callback when the button is pressed.
            child: const Text('Retry'), // Text displayed on the button.
          ),
        ],
      ),
    );
  }
}
