// screens/dashboard_content_screen.dart

import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';
import 'package:local_plant_identification/screens/plant_configs/empty_data_message.dart';
import 'package:local_plant_identification/screens/plant_configs/error_display.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';
import 'package:local_plant_identification/screens/quizs/flowers_quiz.dart';
import 'package:local_plant_identification/screens/quizs/herbs_quiz.dart';
import 'package:local_plant_identification/screens/quizs/trees_quiz.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_plant_identification/widgets/localization_helper.dart';

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

  // --- _buildPlantCard method ---
  Widget _buildPlantCard(BuildContext context, Map<String, dynamic> plant) {
    final String localizedName = getLocalizedValue(context, plant, 'Name');
    final String? imageUrl = plant['image'];
    final String? plantId = plant['\$id'];

    return GestureDetector(
      onTap: () {
        if (plantId != null) {
          final navigator = Navigator.of(context);
          navigator.push(
            MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plantData: plant),
            ),
          );
        } else {
          // --- Keep this SnackBar error hardcoded (developer focus) ---
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
        width: 130,
        margin: const EdgeInsets.only(right: 10.0),
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
                  child: (imageUrl != null && imageUrl.isNotEmpty)
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
                            // Tooltip for image error - can remain hardcoded or use l10n.imageUnavailableError
                            return Tooltip(
                              message: 'Image unavailable',
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 50,
                                color: Colors.grey[500],
                              ),
                            );
                          },
                        )
                      : Tooltip(
                          message: 'Image unavailable',
                          child: Icon(
                            Icons.image_outlined,
                            size: 50,
                            color: Colors.grey[500],
                          ),
                        ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.black26),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  localizedName, // Dynamic localized name from helper
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

  // Helper to get localized category name from item_type
  String _getLocalizedCategoryName(BuildContext context, String itemType) {
    final l10n = AppLocalizations.of(context)!;
    switch (itemType) {
      case 'Flower':
        return l10n.filterFlowers;
      case 'Herb':
        return l10n.filterHerbs;
      case 'Tree':
        return l10n.filterTrees;
      default:
        return itemType;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the AppLocalizations instance for static text
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futurePlants,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (snapshot.hasError) {
          // --- Revert ErrorDisplay message to hardcoded English ---
          return ErrorDisplay(
            errorMessage:
                'Failed to load plant data.\nPlease try again.\nError: ${snapshot.error}', // Hardcoded English
            onRetry: _loadAllPlants,
          );
          // --- End Revert ---
        }

        final allPlants = snapshot.data ?? [];

        // Group plants by item_type (Flower, Herb, Tree)
        final Map<String, List<Map<String, dynamic>>> groupedPlants = {};
        final Set<String> availableCategories = {};
        if (allPlants.isNotEmpty) {
          for (var plant in allPlants) {
            final type = plant['item_type'] ?? 'Unknown';
            if (type == 'Unknown') continue;

            if (groupedPlants.containsKey(type)) {
              groupedPlants[type]!.add(plant);
            } else {
              groupedPlants[type] = [plant];
            }
            availableCategories.add(type);
          }
        }

        const categoryDisplayOrder = ['Flower', 'Herb', 'Tree'];
        final sortedCategories = categoryDisplayOrder
            .where((type) => availableCategories.contains(type))
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            _loadAllPlants();
            await _futurePlants;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Localized Title ---
                  Text(
                    l10n.plantCategoriesTitle, // Localized
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  const SizedBox(height: 8),

                  // --- Plant Category Sections ---
                  if (groupedPlants.isNotEmpty) ...[
                    for (var categoryType in sortedCategories)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  _getLocalizedCategoryName(
                                    context,
                                    categoryType,
                                  ), // Localized category name
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      groupedPlants[categoryType]!.length,
                                  itemBuilder: (context, index) {
                                    final plant =
                                        groupedPlants[categoryType]![index];
                                    return _buildPlantCard(context, plant);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ] else if (snapshot.connectionState ==
                      ConnectionState.done) ...[
                    // Use localized empty message
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: EmptyDataMessage(
                        message: "No plants available", // Hardcoded message
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // --- Localized Quiz Selection Section ---
                  Text(
                    l10n.quizTypeTitle, // Localized
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                          child: Text(
                            l10n.quizFlowersButton, // Localized
                            style: const TextStyle(
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
                          child: Text(
                            l10n.quizHerbsButton, // Localized
                            style: const TextStyle(
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
                          child: Text(
                            l10n.quizTreesButton, // Localized
                            style: const TextStyle(
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

                  // --- Localized About Us Section ---
                  Text(
                    l10n.aboutUsTitle, // Localized
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  Text(
                    l10n.aboutUsContent, // Localized
                    style: const TextStyle(fontSize: 16, color: Colors.black),
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
