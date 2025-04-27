// screens/favourite/favorites_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/screens/favourite/favorites_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:local_plant_identification/widgets/localization_helper.dart';

// Import your Plant Detail Screen and the Appwrite Service
import '../plant_configs/plant_detail_screen.dart' as detail_screen;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Use function from detail_screen (consider moving getCurrentUserId to a shared auth service/util)
  final String? userId = detail_screen.getCurrentUserId();
  final AppwriteService _appwriteService = AppwriteService();

  // --- Helper Function _fetchFavoritePlantDetails (No changes needed) ---
  Future<List<Map<String, dynamic>>> _fetchFavoritePlantDetails(
    List<String> plantIds,
  ) async {
    if (plantIds.isEmpty) {
      return [];
    }
    final List<Future<Map<String, dynamic>?>> futurePlantDetails =
        plantIds.map((id) => _appwriteService.getPlantDetailsById(id)).toList();
    try {
      final List<Map<String, dynamic>?> results = await Future.wait(
        futurePlantDetails,
      );
      final List<Map<String, dynamic>> plantDetails = results
          .where((result) => result != null)
          .cast<Map<String, dynamic>>()
          .toList();
      if (plantDetails.length != plantIds.length) {
        print(
          "Warning: Some favorite plant IDs could not be found in Appwrite.",
        );
      }
      return plantDetails;
    } catch (e) {
      print("Error fetching one or more favorite plant details: $e");
      rethrow; // Rethrow to be caught by FutureBuilder
    }
  }
  // --- End Helper Function ---

  // --- Helper Function to Handle Unfavorite Action (Uses hardcoded messages as keys are missing in template) ---
  Future<void> _handleUnfavorite(
      String plantId, String localizedPlantName) async {
    // Ensure context is available before async gap
    if (!mounted) return;
    // final l10n = AppLocalizations.of(context)!; // Not needed for hardcoded messages
    final messenger = ScaffoldMessenger.of(context); // Store messenger

    try {
      await removeFavoritePlant(plantId);
      // Check mount status again before showing snackbar
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          // --- Hardcoded English message (key missing in provided template) ---
          content: Text('$localizedPlantName removed from favorites.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error removing favorite from list: $e");
      // Check mount status again before showing snackbar
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          // --- Hardcoded English message (key missing in provided template) ---
          content: Text('Error removing $localizedPlantName: ${e.toString()}'),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  // --- End Helper Function ---

  @override
  Widget build(BuildContext context) {
    // Get l10n instance for the tooltip
    final l10n = AppLocalizations.of(context)!;

    if (userId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          // --- Hardcoded English message (key missing in provided template) ---
          child: Text(
            'Please log in to see your favorite plants.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    // Pass l10n down to the builder method for the tooltip
    return _buildFavoritesList(l10n);
  }

  Widget _buildFavoritesList(AppLocalizations l10n) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId!) // userId is guaranteed non-null here
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError) {
          print("Firestore Error: ${userSnapshot.error}");
          // --- Hardcoded English message (key missing in provided template) ---
          return const Center(
            child: Text(
              'Error loading favorites list.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          // --- Hardcoded English message (key missing in provided template) ---
          return const Center(
            child: Text(
              'You have no favorite plants yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final List<dynamic> favoriteIdsDynamic =
            userData?['favoritePlantIds'] as List<dynamic>? ?? [];
        final List<String> favoritePlantIds =
            favoriteIdsDynamic.map((id) => id.toString()).toList();

        if (favoritePlantIds.isEmpty) {
          // --- Hardcoded English message (key missing in provided template) ---
          return const Center(
            child: Text(
              'You have no favorite plants yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Fetch details using the helper
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchFavoritePlantDetails(favoritePlantIds),
          builder: (context, plantDetailsSnapshot) {
            if (plantDetailsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildLoadingPlaceholders(favoritePlantIds.length);
            }
            if (plantDetailsSnapshot.hasError) {
              print("Appwrite Fetch Error: ${plantDetailsSnapshot.error}");
              // --- Hardcoded English message (key missing in provided template) ---
              return Center(
                child: Text(
                  'Error loading plant details: ${plantDetailsSnapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!plantDetailsSnapshot.hasData) {
              // --- Hardcoded English message (key missing in provided template) ---
              return const Center(
                child: Text(
                  'Could not load details for favorite plants.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final List<Map<String, dynamic>> favoritePlants =
                plantDetailsSnapshot.data!;

            if (favoritePlants.isEmpty && favoritePlantIds.isNotEmpty) {
              // --- Hardcoded English message (key missing in provided template) ---
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Could not find details for saved favorites. They may have been removed or there was an error.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }
            if (favoritePlants.isEmpty) {
              // --- Hardcoded English message (key missing in provided template) ---
              return const Center(
                child: Text(
                  'You have no favorite plants yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Build the list using localized data for name, localized tooltip
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 8.0,
              ),
              itemCount: favoritePlants.length,
              itemBuilder: (context, index) {
                final plantData = favoritePlants[index];
                final String? plantId = plantData['\$id'];

                if (plantId == null) {
                  print(
                      "Warning: Favorite plant data missing '\$id'. Index: $index");
                  return const SizedBox.shrink();
                }

                // --- Use getLocalizedValue from the imported helper ---
                final String localizedName =
                    getLocalizedValue(context, plantData, 'Name');
                // --- End localization for name ---

                final String? imageUrl = plantData['image'];

                // Card Layout
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => detail_screen.PlantDetailScreen(
                            plantData: plantData,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Image Area
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: (imageUrl != null && imageUrl.isNotEmpty)
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            color: Colors.grey[500],
                                            size: 40,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey[500],
                                        size: 40,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Text Area (Use localizedName)
                          Expanded(
                            child: Text(
                              localizedName, // Display localized name
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Favorite Icon Button
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28,
                            ),
                            // --- Use localized tooltip from .arb template ---
                            tooltip: l10n.removeFromFavoritesTooltip,
                            visualDensity: VisualDensity.standard,
                            onPressed: () {
                              _handleUnfavorite(plantId, localizedName);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Placeholder widget (No changes needed)
  Widget _buildLoadingPlaceholders(int count) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      itemCount: count,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, color: Colors.grey[300]),
                      const SizedBox(height: 6),
                      Container(
                        height: 20,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.favorite_border, color: Colors.grey[300], size: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}
