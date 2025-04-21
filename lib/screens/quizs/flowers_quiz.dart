import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/quizs/quiz_dialogs.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/widgets/custom_quiz_option_button.dart';

class FlowerQuiz extends StatefulWidget {
  const FlowerQuiz({super.key});

  @override
  State<FlowerQuiz> createState() => _FlowerQuizState();
}

class _FlowerQuizState extends State<FlowerQuiz> {
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
      // Reset quiz state if re-fetching
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
    });

    try {
      // Initialize Appwrite Client
      client = Client()
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId);
      // For self-signed certificates (if using self-hosted Appwrite)
      // .setSelfSigned(status: true);

      // Initialize Databases service
      databases = Databases(client);

      // Fetch questions
      final response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.flowersquizCollectionId,
        // You might want to add queries here, e.g., limit, order, etc.
        // queries: [Query.limit(10)]
      );

      if (response.documents.isNotEmpty) {
        setState(() {
          _questions =
              response.documents
                  .map((doc) => Question.fromAppwriteDoc(doc))
                  .toList();
          // Optional: Shuffle questions initially
          _questions.shuffle();
          _isLoading = false;
        });
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
      print("General Error: $e");
      setState(() {
        _error = "An unexpected error occurred: $e";
        _isLoading = false;
      });
    }
  }

  void _answerQuestion(int selectedIndex) {
    if (_answered) return; // Prevent answering multiple times

    final currentQuestion = _questions[_currentIndex];
    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _answered = true; // Mark as answered
      if (selectedIndex == currentQuestion.correctAnswerIndex) {
        _score++;
      }
    });

    // Optional: Automatically move to the next question after a delay
    // Future.delayed(const Duration(seconds: 1), () {
    //   _nextQuestion();
    // });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null; // Reset selection
        _answered = false; // Allow answering next question
      });
    } else {
      // End of quiz - show results
      _showResultsDialog();
    }
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return QuizResultsDialog(
          score: _score,
          totalQuestions: _questions.length,
          onPlayAgain: _resetQuiz,
          onClose: () {
            Navigator.of(context).pop(); // Close the dialog
            // Optionally navigate away or just stay on the results screen
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
      // Optional: Re-fetch or shuffle questions if desired
      // _initializeAppwriteAndFetchQuestions(); // If you want fresh data
      _questions.shuffle(); // Simple shuffle for replayability
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a dark theme for the Scaffold background
    return Scaffold(
      backgroundColor: Colors.white, // Very dark background
      appBar: AppBar(
        title: const Text('Flowers Quiz'),
        backgroundColor: const Color(
          0xFFA8E6A2,
        ), // Slightly lighter dark for AppBar
        foregroundColor: Colors.black, // White title text
        elevation: 0, // No shadow
        actions: [
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
      body: Center(child: _buildBody()),
      // Keep the FAB for navigation, but style it
      floatingActionButton:
          _answered && _currentIndex < _questions.length
              ? FloatingActionButton.extended(
                onPressed: _nextQuestion,
                backgroundColor: Colors.blueAccent.shade700,
                foregroundColor: Colors.white,
                label: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'Show Results',
                ),
                icon: const Icon(Icons.arrow_forward),
              )
              : null, // Hide button until answered
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: Colors.blueAccent);
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
            const SizedBox(height: 10),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: _initializeAppwriteAndFetchQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Text(
        'No questions available.',
        style: TextStyle(color: Colors.white70),
      );
    }

    // Ensure current index is valid
    if (_currentIndex >= _questions.length) {
      // This case should ideally be handled by the results dialog,
      // but as a fallback:
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResultsDialog());
      return const Text(
        'Quiz finished. Showing results...',
        style: TextStyle(color: Colors.white70),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final bool hasImage =
        currentQuestion.imageUrl != null &&
        currentQuestion.imageUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align top
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Question Text (like the wireframe)
          Text(
            // Add question number dynamically
            "${_currentIndex + 1}. ${currentQuestion.questionText}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black, // black text
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // 2. Image Area (Rounded Square)
          Container(
            height: 200, // Define a fixed height for the image container
            width: 200, // Define a fixed width to make it square
            decoration: BoxDecoration(
              color: Colors.white, // Placeholder background
              borderRadius: BorderRadius.circular(15.0), // Rounded corners
            ),
            child: ClipRRect(
              // Clip the child (Image or Icon) to the rounded corners
              borderRadius: BorderRadius.circular(15.0),
              child:
                  hasImage
                      ? Image.network(
                        currentQuestion.imageUrl!,
                        fit: BoxFit.cover, // Cover the container
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Show placeholder icon on error
                          return const Center(
                            child: Icon(
                              Icons
                                  .image_not_supported_outlined, // Placeholder icon
                              color: Colors.white54,
                              size: 80,
                            ),
                          );
                        },
                      )
                      : const Center(
                        // Show placeholder icon if no image URL
                        child: Icon(
                          Icons
                              .image_outlined, // Generic image placeholder icon
                          color: Colors.white54,
                          size: 80,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 30),

          // 3. Options Grid (2x2)
          GridView.count(
            crossAxisCount: 2, // 2 columns
            shrinkWrap: true, // Important inside SingleChildScrollView
            physics:
                const NeverScrollableScrollPhysics(), // Disable grid scrolling
            mainAxisSpacing: 15.0, // Spacing between rows
            crossAxisSpacing: 15.0, // Spacing between columns
            childAspectRatio: 2.5, // Adjust aspect ratio (Width / Height)
            children: List.generate(currentQuestion.options.length, (index) {
              // Ensure we don't generate more buttons than options available
              if (index >= currentQuestion.options.length) {
                return const SizedBox.shrink(); // Return empty widget if out of bounds
              }

              return QuizOptionButton(
                optionIndex: index,
                optionText: currentQuestion.options[index],
                currentQuestion: currentQuestion,
                selectedAnswerIndex: _selectedAnswerIndex,
                answered: _answered,
                onPressed: () => _answerQuestion(index),
              );
            }),
          ),
          const SizedBox(height: 80), // Space for the FAB if it's shown
        ],
      ),
    );
  }
}
