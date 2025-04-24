// lib/models/question.dart
import 'package:appwrite/models.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? imageUrl; // Make sure this matches your Appwrite attribute name

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl,
  });

  // Factory constructor to create a Question from an Appwrite document
  factory Question.fromAppwriteDoc(Document doc) {
    // Ensure correct data types and handle potential nulls gracefully
    final data = doc.data;
    final List<dynamic> rawOptions = data['options'] ?? [];
    final List<String> stringOptions =
        rawOptions.map((opt) => opt.toString()).toList();

    // Validate correct answer index
    int correctIndex = data['correctAnswerIndex'] ?? -1;
    if (correctIndex < 0 || correctIndex >= stringOptions.length) {
      print(
        "Warning: Invalid correctAnswerIndex (${data['correctAnswerIndex']}) for question ID ${doc.$id}. Defaulting to 0 or handle error.",
      );
      // Decide how to handle: throw error, default to 0, skip question?
      // For now, let's clamp it, but ideally, your data should be valid.
      correctIndex = 0.clamp(0, stringOptions.length - 1);
      if (stringOptions.isEmpty) correctIndex = -1; // Handle empty options case
    }

    return Question(
      id: doc.$id,
      questionText: data['questionText'] ?? 'Missing question text',
      options: stringOptions,
      correctAnswerIndex: correctIndex,
      imageUrl: data['imageUrl'] as String?, // Cast safely
    );
  }
}
