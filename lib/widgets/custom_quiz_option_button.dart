// New Widget for individual quiz options
import 'package:flutter/material.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';

class QuizOptionButton extends StatelessWidget {
  final int optionIndex;
  final String optionText;
  final Question currentQuestion;
  final int? selectedAnswerIndex;
  final bool answered;
  final VoidCallback onPressed;

  const QuizOptionButton({
    super.key,
    required this.optionIndex,
    required this.optionText,
    required this.currentQuestion,
    required this.selectedAnswerIndex,
    required this.answered,
    required this.onPressed,
  });

  // Determine button color based on answer state
  Color _getButtonColor() {
    if (!answered) {
      // Default color before answering
      return Colors.grey.shade800; // Darker grey for options
    }
    // After answering
    if (optionIndex == currentQuestion.correctAnswerIndex) {
      return Colors.green.shade700; // Darker green for correct
    } else if (optionIndex == selectedAnswerIndex) {
      return Colors.red.shade700; // Darker red for incorrect selected
    } else {
      // Other incorrect options (fade them out slightly)
      return Colors.grey.shade900; // Even darker grey
    }
  }

  // Determine text color for buttons for better contrast
  Color _getButtonTextColor() {
    if (!answered) {
      return Colors.white; // White text for default state
    }
    // After answering
    if (optionIndex == currentQuestion.correctAnswerIndex ||
        optionIndex == selectedAnswerIndex) {
      return Colors.white; // White text for highlighted answers (correct/wrong)
    } else {
      return Colors.grey.shade500; // Grey text for non-selected wrong answers
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate A, B, C, D labels
    String optionLabel = String.fromCharCode(
      65 + optionIndex,
    ); // 65 is ASCII for 'A'

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getButtonColor(),
        foregroundColor: _getButtonTextColor(),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0), // Highly rounded corners
        ),
        elevation: answered ? 2 : 5, // Reduce elevation when answered
      ),
      // Disable button if answered, otherwise call onPressed
      onPressed: answered ? null : onPressed,
      child: Text(
        // Format as "A. Option Text"
        "$optionLabel. $optionText",
        textAlign: TextAlign.center,
      ),
    );
  }
}
