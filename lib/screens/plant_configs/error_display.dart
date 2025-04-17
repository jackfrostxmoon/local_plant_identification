import 'package:flutter/material.dart';

/// Displays an error message and a retry button.
class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry; // Function to call when retry is pressed

  const ErrorDisplay({
    required this.errorMessage,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry, // Call the passed function
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
