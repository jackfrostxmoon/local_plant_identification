import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/screens/quizs/quiz_body.dart';
import 'package:local_plant_identification/screens/quizs/quiz_dialogs.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';

class HerbsQuiz extends StatefulWidget {
  const HerbsQuiz({super.key});

  @override
  State<HerbsQuiz> createState() => _HerbsQuizState();
}

class _HerbsQuizState extends State<HerbsQuiz> {
  late Client client;
  late Databases databases;
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  String? _error;
  int? _selectedAnswerIndex; // Track selected answer for feedback
  bool _answered = false; // To disable buttons after answering

  @override
  void initState() {
    super.initState();
    _initializeAppwriteAndFetchQuestions();
  }

  Future<void> _initializeAppwriteAndFetchQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
    });

    try {
      client = Client()
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId);
      databases = Databases(client);

      final response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.herbsquizCollectionId,
        // queries: [Query.limit(10)] // Example query
      );

      if (response.documents.isNotEmpty) {
        // Use the Question model factory
        final List<Question> fetchedQuestions = [];
        for (var doc in response.documents) {
          try {
            fetchedQuestions.add(Question.fromAppwriteDoc(doc));
          } catch (e) {
            print("Error parsing question ${doc.$id}: $e");
            // Optionally skip this question or handle the error differently
          }
        }

        if (fetchedQuestions.isNotEmpty) {
          setState(() {
            _questions = fetchedQuestions;
            _questions.shuffle();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = "No valid questions could be parsed.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = "No questions found in the database.";
          _isLoading = false;
        });
      }
    } on AppwriteException catch (e) {
      print("Appwrite Error: ${e.message}");
      setState(() {
        _error = "Failed to load questions: ${e.message}";
        _isLoading = false;
      });
    } catch (e) {
      print("General Error fetching/parsing questions: $e");
      setState(() {
        _error = "An unexpected error occurred: $e";
        _isLoading = false;
      });
    }
  }

  void _answerQuestion(int selectedIndex) {
    if (_answered || _currentIndex >= _questions.length) return;

    final currentQuestion = _questions[_currentIndex];
    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _answered = true;
      if (selectedIndex == currentQuestion.correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _answered = false;
      });
    } else {
      _showResultsDialog();
    }
  }

  void _showResultsDialog() {
    // Prevent dialog from showing if questions are empty or index is wrong
    if (_questions.isEmpty && !_isLoading) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return QuizResultsDialog(
          score: _score,
          totalQuestions: _questions.length,
          onPlayAgain: () {
            Navigator.of(context).pop(); // Close dialog first
            _resetQuiz();
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
      _isLoading = false; // Ensure loading is false
      _error = null; // Clear errors
      if (_questions.isNotEmpty) {
        _questions.shuffle(); // Shuffle existing questions
      } else {
        // If questions were empty (e.g., due to initial error), retry fetching
        _initializeAppwriteAndFetchQuestions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flowers Quiz'),
        backgroundColor: const Color(0xFFA8E6A2),
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Only show score if questions are loaded and quiz hasn't ended unexpectedly
          if (!_isLoading && _error == null && _questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  'Score: $_score',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      // Use the new QuizBody widget
      body: QuizBody(
        isLoading: _isLoading,
        error: _error,
        questions: _questions,
        currentIndex: _currentIndex,
        selectedAnswerIndex: _selectedAnswerIndex,
        answered: _answered,
        onRetry: _initializeAppwriteAndFetchQuestions,
        onAnswerSelected: _answerQuestion, // Pass the answer handler
        showResultsCallback: _showResultsDialog, // Pass callback for end case
      ),
      floatingActionButton: _buildFab(), // Extracted FAB build logic
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Helper method to build the FAB conditionally
  Widget? _buildFab() {
    // Show FAB only if:
    // - Not loading
    // - No error
    // - Questions are available
    // - An answer has been selected for the current question
    // - There are still questions left or it's the last question
    if (!_isLoading &&
        _error == null &&
        _questions.isNotEmpty &&
        _answered &&
        _currentIndex < _questions.length) {
      // Check index validity
      return FloatingActionButton.extended(
        onPressed: _nextQuestion,
        backgroundColor: const Color(0xFFA8E6A2),
        foregroundColor: Colors.black,
        label: Text(
          _currentIndex < _questions.length - 1
              ? 'Next Question'
              : 'Show Results',
        ),
        icon: const Icon(Icons.arrow_forward),
      );
    }
    return null; // Return null if FAB shouldn't be shown
  }
}
