// screens/quizs/herbs_quiz.dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/screens/quizs/quiz_body.dart';
import 'package:local_plant_identification/screens/quizs/quiz_dialogs.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

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
  String? _error; // Will store HARDCODED error messages
  int? _selectedAnswerIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure context is available for first fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeAppwriteAndFetchQuestions();
      }
    });
  }

  Future<void> _initializeAppwriteAndFetchQuestions() async {
    if (!mounted) return;
    // final l10n = AppLocalizations.of(context)!; // Not needed for hardcoded errors

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
        // --- Use the correct Collection ID for Herbs Quiz ---
        collectionId: AppwriteConfig.herbsquizCollectionId,
      );

      if (response.documents.isNotEmpty) {
        final List<Question> fetchedQuestions = [];
        // Pass context to the factory method
        for (var doc in response.documents) {
          try {
            // Pass context here for localization within the factory
            fetchedQuestions.add(Question.fromAppwriteDoc(doc, context));
          } catch (e) {
            print("Error parsing question ${doc.$id}: $e");
          }
        }

        if (!mounted) return;

        if (fetchedQuestions.isNotEmpty) {
          setState(() {
            _questions = fetchedQuestions;
            _questions.shuffle();
            _isLoading = false;
          });
        } else {
          setState(() {
            // --- Hardcoded Error ---
            _error = "No valid questions could be parsed.";
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          // --- Hardcoded Error ---
          _error = "No questions found in the database.";
          _isLoading = false;
        });
      }
    } on AppwriteException catch (e) {
      print("Appwrite Error: ${e.message}");
      if (!mounted) return;
      setState(() {
        // --- Hardcoded Error ---
        _error =
            "Failed to load questions: ${e.message ?? 'Unknown Appwrite error'}";
        _isLoading = false;
      });
    } catch (e) {
      print("General Error fetching/parsing questions: $e");
      if (!mounted) return;
      setState(() {
        // --- Hardcoded Error ---
        _error = "An unexpected error occurred: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // _answerQuestion remains the same
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

  // _nextQuestion remains the same
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

  // _showResultsDialog remains the same (passes data to localized dialog)
  void _showResultsDialog() {
    if (!mounted || (_questions.isEmpty && !_isLoading)) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return QuizResultsDialog(
          score: _score,
          totalQuestions: _questions.length,
          onPlayAgain: () {
            Navigator.of(dialogContext).pop();
            _resetQuiz();
          },
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  // _resetQuiz remains the same
  void _resetQuiz() {
    if (!mounted) return;
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
      _isLoading = false;
      _error = null; // Clear error on reset

      if (_questions.isNotEmpty) {
        _questions.shuffle();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _initializeAppwriteAndFetchQuestions();
          }
        });
        _isLoading = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get l10n instance for static text (AppBar title, score prefix, FAB)
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // --- Use localized title for Herbs Quiz ---
        title: Text(l10n.quizHerbsTitle), // Localized title
        backgroundColor: const Color(0xFFA8E6A2),
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isLoading && _error == null && _questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${l10n.quizScorePrefix}$_score', // Localized prefix
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      // Pass the potentially hardcoded error message to QuizBody
      body: QuizBody(
        isLoading: _isLoading,
        error: _error, // Pass hardcoded error string if set
        questions: _questions, // Questions are localized via the model
        currentIndex: _currentIndex,
        selectedAnswerIndex: _selectedAnswerIndex,
        answered: _answered,
        onRetry: _initializeAppwriteAndFetchQuestions,
        onAnswerSelected: _answerQuestion,
        showResultsCallback: _showResultsDialog,
      ),
      floatingActionButton: _buildFab(l10n), // Pass l10n to FAB builder
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Helper method to build the FAB conditionally (accepts l10n)
  Widget? _buildFab(AppLocalizations l10n) {
    if (!_isLoading &&
        _error == null &&
        _questions.isNotEmpty &&
        _answered &&
        _currentIndex < _questions.length) {
      return FloatingActionButton.extended(
        onPressed: _nextQuestion,
        backgroundColor: const Color(0xFFA8E6A2),
        foregroundColor: Colors.black,
        label: Text(
          // Use localized labels
          _currentIndex < _questions.length - 1
              ? l10n.quizNextButton
              : l10n.quizShowResultsButton,
        ),
        icon: const Icon(Icons.arrow_forward),
      );
    }
    return null;
  }
}
