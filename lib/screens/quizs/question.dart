// screens/quizs/question.dart (EXAMPLE - Adapt to your actual model)
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart'; // Required for BuildContext
// Assuming the helper functions are in this path
import 'package:local_plant_identification/widgets/localization_helper.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? imageUrl; // Make imageUrl nullable

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl,
  });

  // Factory constructor modified to use localization helper
  factory Question.fromAppwriteDoc(Document doc, BuildContext context) {
    final data = doc.data;

    // Use helper functions to get localized text and options
    final String localizedQuestion = getLocalizedValue(
      context,
      data,
      'Questions', // Base key for question text (Correct positional argument)
      // REMOVED: String baseKey, {  <-- Removed erroneous part
      fallbackValue: 'Error: Missing question text', // Correct named argument
    );

    // This call was already correct
    final List<String> localizedOptions = getLocalizedList(
      context,
      data,
      'Options', // Base key for options list
      fallbackValue: ['Error', 'Missing', 'Options'], // Provide a fallback
    );

    // Safely get the correct answer index, default to 0 if missing/invalid
    int correctIndex = 0; // Default index
    final dynamic correctIndexData = data['Correct_Answer_Index'];
    if (correctIndexData is int) {
      correctIndex = correctIndexData;
    } else if (correctIndexData is String) {
      correctIndex = int.tryParse(correctIndexData) ?? 0;
    }
    // Ensure index is within bounds of the fetched options
    if (correctIndex < 0 || correctIndex >= localizedOptions.length) {
      print(
          "Warning: Correct answer index ($correctIndex) out of bounds for question ${doc.$id}. Defaulting to 0.");
      correctIndex = 0; // Default to first option if index is invalid
    }

    return Question(
      id: doc.$id,
      questionText: localizedQuestion,
      options: localizedOptions,
      correctAnswerIndex: correctIndex,
      imageUrl: data['Image'] as String?, // Cast safely
    );
  }
}
