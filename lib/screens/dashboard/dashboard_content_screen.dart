// screens/dashboard_content_screen.dart

import 'package:flutter/material.dart';
// Import PlantDetailScreen if not already imported at the top
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';
import 'package:local_plant_identification/screens/plant_configs/empty_data_message.dart';
import 'package:local_plant_identification/screens/plant_configs/error_display.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';
import 'package:local_plant_identification/screens/quizs/flowers_quiz.dart';
import 'package:local_plant_identification/screens/quizs/herbs_quiz.dart';
import 'package:local_plant_identification/screens/quizs/trees_quiz.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
// Remove the CategorySection import if it's no longer used elsewhere
// import 'package:local_plant_identification/screens/plant_configs/category_section.dart';

class DashboardContentScreen extends StatefulWidget {
  const DashboardContentScreen({super.key});

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

  void _loadAllPlants() {
    if (mounted) {
      setState(() {
        _futurePlants = _appwriteService.fetchAllPlants();
      });
    }
  }

  // --- PASTE THE _buildPlantCard method HERE ---
  Widget _buildPlantCard(BuildContext context, Map<String, dynamic> plant) {
    final String name = plant['Name'] ?? 'Unknown';
    final String? imageUrl = plant['image']; // Key for the image URL
    final String? plantId = plant['\$id']; // Key for the document ID

    return GestureDetector(
      onTap: () {
        if (plantId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plantData: plant),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Cannot view details. Plant ID missing.'),
              backgroundColor: Colors.red,
            ),
          );
          print("Error: Missing '\$id' in plant data for navigation: $plant");
        }
      },
      child: Container(
        width: 130, // Set a fixed width for each card
        margin: const EdgeInsets.only(right: 10.0), // Spacing between cards
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child:
                      (imageUrl != null && imageUrl.isNotEmpty)
                          ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported_outlined,
                                size: 50,
                                color: Colors.grey[500],
                              );
                            },
                          )
                          : Icon(
                            Icons.image_outlined,
                            size: 50,
                            color: Colors.grey[500],
                          ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.black26),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // --- END of _buildPlantCard method ---

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futurePlants,
      builder: (context, snapshot) {
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

        final Map<String, List<Map<String, dynamic>>> groupedPlants = {};
        if (allPlants.isNotEmpty) {
          for (var plant in allPlants) {
            // Ensure '$id' is included if not already present from fetch
            // (Our current fetchAllPlants should include it via _fetchCollectionData)
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

        return RefreshIndicator(
          onRefresh: () async {
            _loadAllPlants();
            await _futurePlants;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0, // Reduced horizontal padding a bit
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title remains the same ---
                  const Text(
                    'Plant Categories', // Changed title slightly
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  const SizedBox(height: 8), // Space after divider
                  // --- Plant Category Sections (NEW LAYOUT) ---
                  if (allPlants.isNotEmpty) ...[
                    for (var categoryName in categoryOrder)
                      if (groupedPlants.containsKey(categoryName) &&
                          groupedPlants[categoryName]!.isNotEmpty)
                        Padding(
                          // Add padding between category sections
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              // Background and border for the category container
                              color: Colors.white, // White background
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Title inside the container
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Text(
                                    categoryName, // e.g., "Flowers"
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                // Horizontal List of Plant Cards
                                SizedBox(
                                  height:
                                      180, // Define height for the horizontal list area
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        groupedPlants[categoryName]!.length,
                                    itemBuilder: (context, index) {
                                      final plant =
                                          groupedPlants[categoryName]![index];
                                      // Use the helper method to build each card
                                      return _buildPlantCard(context, plant);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 24), // Space before Quiz section
                  ] else if (snapshot.connectionState ==
                      ConnectionState.done) ...[
                    // --- Empty Data Message ---
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: EmptyDataMessage(
                        message: 'No plant categories to display.',
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // --- Quiz Selection Section (Remains the same) ---
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

                  // --- About Us Section (Remains the same) ---
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
