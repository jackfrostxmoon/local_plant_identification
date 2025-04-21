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
      return Color(0xFFA8E6A2);
    }
    if (optionIndex == currentQuestion.correctAnswerIndex) {
      return Colors.green;
    }
    if (optionIndex == selectedAnswerIndex) {
      return Colors.red;
    }
    return Colors.grey;
  }

  // Determine text color for buttons for better contrast
  Color _getButtonTextColor() {
    if (!answered) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    String optionLabel = String.fromCharCode(65 + optionIndex);

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.grey.shade400; // Color when button is pressed
          }
          return _getButtonColor();
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white; // Text color when button is pressed
          }
          return _getButtonTextColor();
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
        elevation: WidgetStateProperty.resolveWith<double>(
          (states) => answered ? 2 : 5,
        ),
      ),
      onPressed: answered ? null : onPressed,
      child: Text("$optionLabel. $optionText", textAlign: TextAlign.center),
    );
  }
}
