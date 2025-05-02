import 'package:flutter/material.dart';

/// Displays an error message and a retry button centered on the screen.
class ErrorDisplay extends StatelessWidget {
  final String errorMessage; // The message describing the error.
  final VoidCallback
      onRetry; // Function to call when the retry button is pressed.

  // Constructor for the ErrorDisplay widget.
  const ErrorDisplay({
    required this.errorMessage,
    required this.onRetry, // The retry callback must be provided.
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding around the content.
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // Vertically center the column's children.
          children: [
            // Display an error icon.
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16), // Vertical space.
            // Display the error message.
            Text(
              errorMessage, // The message passed to the widget.
              textAlign: TextAlign.center, // Center the text horizontally.
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16), // Style for the error message.
            ),
            const SizedBox(height: 16), // Vertical space.
            // Display the retry button.
            ElevatedButton(
              onPressed:
                  onRetry, // Call the provided onRetry function when pressed.
              child: const Text('Retry'), // Text on the button.
            ),
          ],
        ),
      ),
    );
  }
}
