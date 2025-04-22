import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/category_section.dart';
import 'package:local_plant_identification/screens/plant_configs/empty_data_message.dart';
import 'package:local_plant_identification/screens/plant_configs/error_display.dart';
import 'package:local_plant_identification/screens/plant_configs/loading_indicator.dart';
import 'package:local_plant_identification/screens/quizs/flowers_quiz.dart';
import 'package:local_plant_identification/screens/quizs/herbs_quiz.dart';
import 'package:local_plant_identification/screens/quizs/trees_quiz.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';

class DashboardContentScreen extends StatefulWidget {
  // Add a callback for the refresh button if needed from the parent AppBar
  // final VoidCallback? onRefreshRequested;

  const DashboardContentScreen({
    super.key,
    /* this.onRefreshRequested */
  });

  @override
  State<DashboardContentScreen> createState() => _DashboardContentScreenState();
}

class _DashboardContentScreenState extends State<DashboardContentScreen> {
  late Future<List<Map<String, dynamic>>> _futurePlants;
  final AppwriteService _appwriteService = AppwriteService();

  @override
  void initState() {
    super.initState();
    _loadAllPlants();
  }

  // Make this public or create a public wrapper if triggered from parent
  void _loadAllPlants() {
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _futurePlants = _appwriteService.fetchAllPlants();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The FutureBuilder and its content goes here
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futurePlants,
      builder: (context, snapshot) {
        // Handle Loading and Error states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (snapshot.hasError) {
          return ErrorDisplay(
            errorMessage:
                'Failed to load plant data.\nPlease try again.\n${snapshot.error}',
            onRetry: _loadAllPlants, // Retry calls the local method
          );
        }

        final allPlants = snapshot.data ?? [];

        // --- Group plants by type ---
        final Map<String, List<Map<String, dynamic>>> groupedPlants = {};
        if (allPlants.isNotEmpty) {
          for (var plant in allPlants) {
            final type = plant['item_type'] ?? 'Unknown';
            final groupKey =
                (type == 'Flower')
                    ? 'Flowers'
                    : (type == 'Herb')
                    ? 'Herbs'
                    : (type == 'Tree')
                    ? 'Trees'
                    : 'Unknown';

            if (groupedPlants.containsKey(groupKey)) {
              groupedPlants[groupKey]!.add(plant);
            } else {
              groupedPlants[groupKey] = [plant];
            }
          }
        }

        const categoryOrder = ['Flowers', 'Herbs', 'Trees'];

        // --- Build the combined list ---
        // Use RefreshIndicator if you want pull-to-refresh
        return RefreshIndicator(
          onRefresh: () async {
            _loadAllPlants(); // Trigger refresh
            await _futurePlants; // Wait for the future to complete
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plant Categories',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  // --- Plant Category Sections ---
                  if (allPlants.isNotEmpty) ...[
                    for (var categoryName in categoryOrder)
                      if (groupedPlants.containsKey(categoryName) &&
                          groupedPlants[categoryName]!.isNotEmpty)
                        CategorySection(
                          title: categoryName,
                          plants: groupedPlants[categoryName]!,
                        ),
                    const SizedBox(height: 24),
                  ] else if (snapshot.connectionState ==
                      ConnectionState.done) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: EmptyDataMessage(
                        message: 'No plant categories to display.',
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // --- Quiz Selection Section ---
                  const Text(
                    'Quiz Type',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FlowerQuiz(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFFA8E6A2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Flowers',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HerbsQuiz(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFFA8E6A2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Herbs',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TreesQuiz(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFFA8E6A2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Trees',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  const Text(
                    'This app is designed to help you identify and learn about various plants.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 20), // Add padding at the bottom
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
