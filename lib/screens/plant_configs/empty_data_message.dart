import 'package:flutter/material.dart';

/// Displays a message indicating no data was found.
class EmptyDataMessage extends StatelessWidget {
  final String message;

  const EmptyDataMessage({
    this.message = 'No data found.', // Default message
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
