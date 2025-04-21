import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/category_section.dart';
import 'package:local_plant_identification/screens/plant_configs/empty_data_message.dart';
import 'package:local_plant_identification/screens/plant_configs/error_display.dart';
import 'package:local_plant_identification/screens/plant_configs/loading_indicator.dart';
import 'package:local_plant_identification/screens/quizs/flowers_quiz.dart';
import 'package:local_plant_identification/screens/quizs/herbs_quiz.dart';
import 'package:local_plant_identification/screens/quizs/trees_quiz.dart';

// Service
import 'package:local_plant_identification/services/appwrite_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, dynamic>>> _futurePlants;
  final AppwriteService _appwriteService = AppwriteService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllPlants();
  }

  void _loadAllPlants() {
    setState(() {
      _futurePlants = _appwriteService.fetchAllPlants();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // You might want to navigate to different screens or update content based on the selected index
    // For now, it just updates the selected index visually.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA8E6A2),
        // Maybe change title to reflect both parts?
        title: const Text('Plant Explorer & Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllPlants,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add logout logic here
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
              onRetry: _loadAllPlants,
            );
          }

          final allPlants = snapshot.data ?? [];

          // --- Group plants by type (No changes needed here) ---
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
          } else if (snapshot.connectionState == ConnectionState.done) {
            // Handle case where fetch is done but list is empty
            // We might still want to show the Quiz section
            // Return just the quiz section or a combined message?
            // For now, let's allow the quiz section to show even if plants are empty.
          }

          const categoryOrder = ['Flowers', 'Herbs', 'Trees'];

          // --- Build the combined list ---
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Plant Category Sections ---
                  if (allPlants.isNotEmpty) ...[
                    // Only show categories if plants exist
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
                  const Divider(color: Colors.black, thickness: 1),
                  const Text(
                    'About Us',
                    style: TextStyle(fontSize: 25, color: Colors.black),
                  ),
                  const Text(
                    'This app is designed to help you identify and learn about various plants.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Added for consistent spacing
      ),
    );
  }
}
