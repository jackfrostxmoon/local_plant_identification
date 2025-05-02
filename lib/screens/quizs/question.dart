//Import all the necessary packages and files
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/widgets/localization_helper.dart';

// Represents a single quiz question with its text, options, correct answer, and optional image.
class Question {
  final String id; // Unique identifier for the question from Appwrite.
  final String questionText; // The localized text of the question.
  final List<String> options; // The localized list of answer options.
  final int
      correctAnswerIndex; // The index of the correct answer in the options list.
  final String?
      imageUrl; // Optional URL for an image associated with the question.

  // Constructor for the Question class.
  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl, // imageUrl is nullable.
  });

  // Factory constructor to create a Question object from an Appwrite Document.
  // It uses the localization helper to get localized question text and options.
  factory Question.fromAppwriteDoc(Document doc, BuildContext context) {
    final data = doc.data; // Get the data map from the Appwrite document.

    // Use the localization helper to get the localized question text.
    // It looks for keys like 'Questions', 'Questions_MS', 'Questions_CN' based on the current locale.
    final String localizedQuestion = getLocalizedValue(
      context, // Provides the current locale.
      data, // The data map from the Appwrite document.
      'Questions', // The base key for the question text.
      fallbackValue:
          'Error: Missing question text', // Fallback if no localized text is found.
    );

    // Use the localization helper to get the localized list of options.
    // It looks for keys like 'Options', 'Options_MS', 'Options_CN' based on the current locale.
    final List<String> localizedOptions = getLocalizedList(
      context, // Provides the current locale.
      data, // The data map from the Appwrite document.
      'Options', // The base key for the options list.
      fallbackValue: [
        'Error',
        'Missing',
        'Options'
      ], // Fallback list if no localized options are found.
    );

    // Safely extract the correct answer index from the document data.
    // Handles cases where the data might be missing or in a different format.
    int correctIndex = 0; // Default index if data is missing or invalid.
    final dynamic correctIndexData =
        data['Correct_Answer_Index']; // Get the data for the correct index.
    if (correctIndexData is int) {
      correctIndex = correctIndexData; // If it's an int, use it directly.
    } else if (correctIndexData is String) {
      // If it's a String, try to parse it as an integer. Default to 0 if parsing fails.
      correctIndex = int.tryParse(correctIndexData) ?? 0;
    }
    // Ensure the retrieved correct index is within the bounds of the available options.
    // If not, default to 0 and print a warning.
    if (correctIndex < 0 || correctIndex >= localizedOptions.length) {
      print(
          "Warning: Correct answer index ($correctIndex) out of bounds for question ${doc.$id}. Defaulting to 0.");
      correctIndex = 0; // Default to the first option if the index is invalid.
    }

    // Create and return a new Question object with the extracted and localized data.
    return Question(
      id: doc.$id, // Use the document ID as the question ID.
      questionText: localizedQuestion, // The localized question text.
      options: localizedOptions, // The localized list of options.
      correctAnswerIndex: correctIndex, // The validated correct answer index.
      imageUrl: data['Image']
          as String?, // Safely cast the 'Image' data to a nullable String.
    );
  }
}
