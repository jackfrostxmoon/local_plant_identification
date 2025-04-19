// lib/main.dart
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
// Your question model

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
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E), // Dark background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Quiz Finished!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Your final score is $_score out of ${_questions.length}.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.lightBlueAccent, // Text color
              ),
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _resetQuiz();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey, // Text color
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Optionally navigate away or just stay on the results screen
              },
            ),
          ],
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

  // Determine button color based on answer state
  Color _getButtonColor(int index, Question currentQuestion) {
    if (!_answered) {
      // Default color before answering
      return Colors.grey.shade800; // Darker grey for options
    }
    // After answering
    if (index == currentQuestion.correctAnswerIndex) {
      return Colors.green.shade700; // Darker green for correct
    } else if (index == _selectedAnswerIndex) {
      return Colors.red.shade700; // Darker red for incorrect selected
    } else {
      // Other incorrect options (fade them out slightly)
      return Colors.grey.shade900; // Even darker grey
    }
  }

  // Determine text color for buttons for better contrast
  Color _getButtonTextColor(int index, Question currentQuestion) {
    if (!_answered) {
      return Colors.white; // White text for default state
    }
    // After answering
    if (index == currentQuestion.correctAnswerIndex ||
        index == _selectedAnswerIndex) {
      return Colors.white; // White text for highlighted answers (correct/wrong)
    } else {
      return Colors.grey.shade500; // Grey text for non-selected wrong answers
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a dark theme for the Scaffold background
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Very dark background
      appBar: AppBar(
        title: const Text('Flowers Quiz'),
        backgroundColor: const Color(
          0xFF1E1E1E,
        ), // Slightly lighter dark for AppBar
        foregroundColor: Colors.white, // White title text
        elevation: 0, // No shadow
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
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
              color: Colors.white, // White text
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // 2. Image Area (Rounded Square)
          Container(
            height: 200, // Define a fixed height for the image container
            width: 200, // Define a fixed width to make it square
            decoration: BoxDecoration(
              color: Colors.grey.shade800, // Placeholder background
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
              // Generate A, B, C, D labels
              String optionLabel = String.fromCharCode(
                65 + index,
              ); // 65 is ASCII for 'A'

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(index, currentQuestion),
                  foregroundColor: _getButtonTextColor(index, currentQuestion),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ), // Highly rounded corners
                  ),
                  elevation:
                      _answered ? 2 : 5, // Reduce elevation when answered
                ),
                // Disable button if answered, otherwise call _answerQuestion
                onPressed: _answered ? null : () => _answerQuestion(index),
                child: Text(
                  // Format as "A. Option Text"
                  "$optionLabel. ${currentQuestion.options[index]}",
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
          const SizedBox(height: 80), // Space for the FAB if it's shown
        ],
      ),
    );
  }
}
