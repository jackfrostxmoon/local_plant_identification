import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/category_section.dart';
import 'package:local_plant_identification/screens/plant_configs/empty_data_message.dart';
import 'package:local_plant_identification/screens/plant_configs/error_display.dart';
import 'package:local_plant_identification/screens/plant_configs/loading_indicator.dart';
import 'package:local_plant_identification/screens/quizs/quiz_screen.dart';
import 'package:local_plant_identification/screens/quizs/quiz_type_button.dart';
import 'package:local_plant_identification/screens/quizs/quiz_type_header.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Maybe change title to reflect both parts?
        title: const Text('Plant Explorer & Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllPlants,
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

          const categoryOrder = ['Flowers', 'Herbs', 'Trees', 'Unknown'];

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
                  const QuizTypeHeader(),
                  const SizedBox(height: 8),
                  const QuizTypeButton(plantType: PlantType.flowers),
                  const QuizTypeButton(plantType: PlantType.herbs),
                  const QuizTypeButton(plantType: PlantType.trees),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
