import 'package:flutter/material.dart';

class QuizTypeHeader extends StatelessWidget {
  const QuizTypeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
        top: 16.0,
        left: 4.0,
        right: 4.0,
      ), // Added horizontal padding
      child: Row(
        children: [
          Text(
            'Quiz Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold, // Make label bold
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              thickness: 1.5, // Make divider slightly thicker
              color: Colors.black, // Black divider
            ),
          ),
        ],
      ),
    );
  }
}
