import 'package:appwrite/models.dart';

class Question {
  // ... (keep existing Question class code)
  final String id; // Appwrite document ID
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? imageUrl; // Nullable image URL

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl,
  });

  factory Question.fromAppwriteDoc(Document doc) {
    List<String> parsedOptions = [];
    if (doc.data['Options'] is List) {
      parsedOptions = List<String>.from(
        doc.data['Options'].map((item) => item.toString()),
      );
    }
    String? imageUrl = doc.data['Image'];
    if (imageUrl != null && imageUrl.trim().isEmpty) {
      imageUrl = null;
    }
    return Question(
      id: doc.$id,
      questionText: doc.data['Questions'] ?? 'Error: Missing question text',
      options: parsedOptions,
      correctAnswerIndex: doc.data['Correct_Answer_Index'] ?? 0,
      imageUrl: imageUrl,
    );
  }
}
