// screens/quizs/trees_quiz.dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/question.dart';
import 'package:local_plant_identification/screens/quizs/quiz_body.dart';
import 'package:local_plant_identification/screens/quizs/quiz_dialogs.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

// A screen for the Trees Quiz.
class TreesQuiz extends StatefulWidget {
  const TreesQuiz({super.key});

  @override
  State<TreesQuiz> createState() => _TreesQuizState();
}

class _TreesQuizState extends State<TreesQuiz> {
  // Appwrite client and database instances.
  late Client client;
  late Databases databases;
  // List to hold the quiz questions.
  List<Question> _questions = [];
  // Index of the current question being displayed.
  int _currentIndex = 0;
  // The user's current score.
  int _score = 0;
  // Flag to indicate if questions are currently being loaded.
  bool _isLoading = true;
  // Stores hardcoded error messages if data fetching fails.
  String? _error;
  // Index of the answer selected by the user for the current question.
  int? _selectedAnswerIndex;
  // Flag to indicate if the current question has been answered.
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    // Schedule a callback to initialize Appwrite and fetch questions after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeAppwriteAndFetchQuestions();
      }
    });
  }

  // Initializes Appwrite client and fetches quiz questions from the database.
  Future<void> _initializeAppwriteAndFetchQuestions() async {
    // Check if the widget is still mounted before updating the state.
    if (!mounted) return;

    // Reset the state to indicate loading and clear previous data/errors.
    setState(() {
      _isLoading = true;
      _error = null;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
    });

    try {
      // Initialize Appwrite client with endpoint and project ID.
      client = Client()
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId);
      // Initialize Appwrite Databases service.
      databases = Databases(client);

      // List documents from the specified database and collection for trees quiz questions.
      // --- Use the correct Collection ID for Trees Quiz ---
      final response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.treesquizCollectionId,
      );

      // Process the fetched documents if the response is not empty.
      if (response.documents.isNotEmpty) {
        final List<Question> fetchedQuestions = [];
        // Iterate through the documents and parse them into Question objects.
        // Pass context to the factory method for localization within the model.
        for (var doc in response.documents) {
          try {
            // Pass context here for localization within the factory
            fetchedQuestions.add(Question.fromAppwriteDoc(doc, context));
          } catch (e) {
            // Print an error if parsing a specific question fails.
            print("Error parsing question ${doc.$id}: $e");
          }
        }

        // Check if the widget is still mounted before updating the state.
        if (!mounted) return;

        // If valid questions were fetched and parsed, update the state.
        if (fetchedQuestions.isNotEmpty) {
          setState(() {
            _questions = fetchedQuestions;
            _questions.shuffle(); // Randomize the order of questions.
            _isLoading = false; // Stop loading.
          });
        } else {
          // If no valid questions were parsed, set a hardcoded error message.
          setState(() {
            _error = "No valid questions could be parsed."; // Hardcoded error.
            _isLoading = false;
          });
        }
      } else {
        // If no documents were found in the collection, set a hardcoded error message.
        if (!mounted) return;
        setState(() {
          _error = "No questions found in the database."; // Hardcoded error.
          _isLoading = false;
        });
      }
    } on AppwriteException catch (e) {
      // Handle Appwrite specific errors.
      print("Appwrite Error: ${e.message}");
      if (!mounted) return;
      setState(() {
        // Set a hardcoded error message including the Appwrite error message.
        _error =
            "Failed to load questions: ${e.message ?? 'Unknown Appwrite error'}"; // Hardcoded error.
        _isLoading = false;
      });
    } catch (e) {
      // Handle any other general errors during fetching or parsing.
      print("General Error fetching/parsing questions: $e");
      if (!mounted) return;
      setState(() {
        // Set a hardcoded general error message.
        _error =
            "An unexpected error occurred: ${e.toString()}"; // Hardcoded error.
        _isLoading = false;
      });
    }
  }

  // Handles the user's answer selection for the current question.
  void _answerQuestion(int selectedIndex) {
    // Do nothing if the question is already answered or if the quiz is finished.
    if (_answered || _currentIndex >= _questions.length) return;
    // Get the current question.
    final currentQuestion = _questions[_currentIndex];
    // Update the state based on the selected answer.
    setState(() {
      _selectedAnswerIndex =
          selectedIndex; // Store the index of the selected answer.
      _answered = true; // Mark the question as answered.
      // Increment the score if the selected answer is correct.
      if (selectedIndex == currentQuestion.correctAnswerIndex) {
        _score++;
      }
    });
  }

  // Moves to the next question or shows the results if it's the last question.
  void _nextQuestion() {
    // If there are more questions, move to the next one.
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++; // Increment the question index.
        _selectedAnswerIndex =
            null; // Clear the selected answer for the new question.
        _answered = false; // Reset the answered flag.
      });
    } else {
      // If it's the last question, show the results dialog.
      _showResultsDialog();
    }
  }

  // Displays the quiz results dialog.
  void _showResultsDialog() {
    // Check if the widget is mounted and if there are questions to prevent showing the dialog prematurely.
    if (!mounted || (_questions.isEmpty && !_isLoading)) return;
    // Show the dialog.
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside.
      builder: (BuildContext dialogContext) {
        // Return the QuizResultsDialog widget.
        return QuizResultsDialog(
          score: _score, // Pass the user's score.
          totalQuestions:
              _questions.length, // Pass the total number of questions.
          onPlayAgain: () {
            // Callback for the "Play Again" button.
            Navigator.of(dialogContext).pop(); // Close the dialog.
            _resetQuiz(); // Reset the quiz.
          },
          onClose: () {
            // Callback for the "Close" button.
            Navigator.of(dialogContext).pop(); // Close the dialog.
          },
        );
      },
    );
  }

  // Resets the quiz to its initial state to play again.
  void _resetQuiz() {
    // Check if the widget is still mounted before updating the state.
    if (!mounted) return;
    // Reset the state variables.
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
      _isLoading = false;
      _error = null; // Clear any previous error message.

      // If there are questions already loaded, shuffle them for a new game.
      if (_questions.isNotEmpty) {
        _questions.shuffle();
      } else {
        // If no questions were loaded previously, re-initialize and fetch them.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _initializeAppwriteAndFetchQuestions();
          }
        });
        _isLoading = true; // Set loading to true while fetching.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the AppLocalizations instance for static localized text (AppBar title, score prefix, FAB labels).
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // --- Use localized title for Trees Quiz ---
        title:
            Text(l10n.quizTreesTitle), // Localized AppBar title for Trees Quiz.
        backgroundColor: const Color(0xFFA8E6A2), // Custom background color.
        foregroundColor: Colors.black, // Text color.
        elevation: 0, // No shadow.
        actions: [
          // Display the score only if not loading, no error, and questions are available.
          if (!_isLoading && _error == null && _questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${l10n.quizScorePrefix}$_score', // Localized prefix followed by the score.
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      // The main body of the quiz screen.
      body: QuizBody(
        isLoading: _isLoading, // Pass the loading state.
        error: _error, // Pass the hardcoded error string if set.
        questions:
            _questions, // Pass the list of questions (which are localized via the model).
        currentIndex: _currentIndex, // Pass the current question index.
        selectedAnswerIndex:
            _selectedAnswerIndex, // Pass the selected answer index.
        answered: _answered, // Pass the answered flag.
        onRetry:
            _initializeAppwriteAndFetchQuestions, // Pass the retry function for errors.
        onAnswerSelected: _answerQuestion, // Pass the answer selection handler.
        showResultsCallback:
            _showResultsDialog, // Pass the function to show results.
      ),
      // The floating action button, built conditionally.
      floatingActionButton: _buildFab(l10n), // Pass l10n to the FAB builder.
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // Position the FAB in the center.
    );
  }

  // Helper method to build the FloatingActionButton conditionally.
  Widget? _buildFab(AppLocalizations l10n) {
    // Show the FAB only if not loading, no error, questions are available,
    // the current question is answered, and it's not the very last question.
    if (!_isLoading &&
        _error == null &&
        _questions.isNotEmpty &&
        _answered &&
        _currentIndex < _questions.length) {
      return FloatingActionButton.extended(
        onPressed: _nextQuestion, // Execute _nextQuestion when pressed.
        backgroundColor: const Color(0xFFA8E6A2), // Custom background color.
        foregroundColor: Colors.black, // Text color.
        label: Text(
          // Display localized labels for "Next Question" or "Show Results".
          _currentIndex < _questions.length - 1
              ? l10n.quizNextButton // Localized text for next question.
              : l10n.quizShowResultsButton, // Localized text for show results.
        ),
        icon: const Icon(Icons.arrow_forward), // Forward arrow icon.
      );
    }
    return null; // Return null if the FAB should not be shown.
  }
}
