import 'package:flutter/material.dart';

/// Displays a message indicating that no data was found, typically centered on the screen.
class EmptyDataMessage extends StatelessWidget {
  final String message; // The message to display when no data is found.

  // Constructor for the EmptyDataMessage widget.
  const EmptyDataMessage({
    this.message = 'No data found.', // Default message if none is provided.
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding around the message.
        child: Text(
          message, // The message to display.
          textAlign: TextAlign.center, // Center the text horizontally.
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600], // Text color (greyed out).
              ), // Text style from the theme, with custom color.
        ),
      ),
    );
  }
}
