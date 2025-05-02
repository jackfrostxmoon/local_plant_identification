import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/screens/favourite/favorites_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:local_plant_identification/widgets/localization_helper.dart';

// Import your Plant Detail Screen and the Appwrite Service
import '../plant_configs/plant_detail_screen.dart' as detail_screen;

// The screen that displays the user's favorite plants.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

// The state management for the FavoritesScreen.
class _FavoritesScreenState extends State<FavoritesScreen> {
  // Get the current user's ID (consider moving getCurrentUserId to a shared auth service/util).
  final String? userId = detail_screen.getCurrentUserId();
  // Instance of the Appwrite service for fetching plant details.
  final AppwriteService _appwriteService = AppwriteService();

  // Asynchronously fetches the details of favorite plants from Appwrite.
  Future<List<Map<String, dynamic>>> _fetchFavoritePlantDetails(
    List<String> plantIds,
  ) async {
    if (plantIds.isEmpty) {
      return [];
    }
    // Create a list of futures to fetch details for each plant ID.
    final List<Future<Map<String, dynamic>?>> futurePlantDetails =
        plantIds.map((id) => _appwriteService.getPlantDetailsById(id)).toList();
    try {
      // Wait for all futures to complete.
      final List<Map<String, dynamic>?> results = await Future.wait(
        futurePlantDetails,
      );
      // Filter out null results and cast to the expected type.
      final List<Map<String, dynamic>> plantDetails = results
          .where((result) => result != null)
          .cast<Map<String, dynamic>>()
          .toList();
      // Warn if some plant IDs could not be found.
      if (plantDetails.length != plantIds.length) {
        print(
          "Warning: Some favorite plant IDs could not be found in Appwrite.",
        );
      }
      return plantDetails;
    } catch (e) {
      // Print and rethrow any errors during fetching.
      print("Error fetching one or more favorite plant details: $e");
      rethrow; // Rethrow to be caught by FutureBuilder
    }
  }

  // Handles the action of removing a plant from favorites.
  Future<void> _handleUnfavorite(
      String plantId, String localizedPlantName) async {
    // Ensure context is available before async gap
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context); // Store messenger

    try {
      // Call the utility function to remove the favorite plant from Firestore.
      await removeFavoritePlant(plantId);
      // Check mount status again before showing snackbar
      if (!mounted) return;
      // Show a success SnackBar.
      messenger.showSnackBar(
        SnackBar(
          content: Text('$localizedPlantName removed from favorites.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error removing favorite from list: $e");
      // Check mount status again before showing snackbar
      if (!mounted) return;
      // Show an error SnackBar if removal fails.
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

    // Show a message if the user is not logged in.
    if (userId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Please log in to see your favorite plants.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    // Pass l10n down to the builder method for the tooltip
    // Build the list of favorites using a StreamBuilder to listen for Firestore changes.
    return _buildFavoritesList(l10n);
  }

  // Builds the list of favorite plants.
  Widget _buildFavoritesList(AppLocalizations l10n) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId!) // userId is guaranteed non-null here
          .snapshots(), // Listen for changes to the user's document.
      builder: (context, userSnapshot) {
        // Show a loading indicator while fetching user data.
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Show an error message if fetching user data fails.
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
        // Show a message if the user document or favorites list doesn't exist.
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          // --- Hardcoded English message (key missing in provided template) ---
          return const Center(
            child: Text(
              'You have no favorite plants yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Extract favorite plant IDs from the user document.
        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final List<dynamic> favoriteIdsDynamic =
            userData?['favoritePlantIds'] as List<dynamic>? ?? [];
        // Convert dynamic list to a list of strings.
        final List<String> favoritePlantIds =
            favoriteIdsDynamic.map((id) => id.toString()).toList();

        // Show a message if the favorite plant IDs list is empty.
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
        // Use a FutureBuilder to fetch the details of the favorite plants.
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchFavoritePlantDetails(favoritePlantIds),
          builder: (context, plantDetailsSnapshot) {
            // Show loading placeholders while fetching plant details.
            if (plantDetailsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildLoadingPlaceholders(favoritePlantIds.length);
            }
            // Show an error message if fetching plant details fails.
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
            // Show a message if no plant details were found.
            if (!plantDetailsSnapshot.hasData) {
              // --- Hardcoded English message (key missing in provided template) ---
              return const Center(
                child: Text(
                  'Could not load details for favorite plants.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Get the list of favorite plant details.
            final List<Map<String, dynamic>> favoritePlants =
                plantDetailsSnapshot.data!;

            // Handle the case where the list of fetched plants is empty but the IDs list was not.
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
            // Show a message if the final list of favorite plants is empty.
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
            // Build the list of favorite plants using a ListView.builder.
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 8.0,
              ),
              itemCount:
                  favoritePlants.length, // The number of favorite plants.
              // Builder function to create each list tile.
              itemBuilder: (context, index) {
                final plantData = favoritePlants[index];
                final String? plantId = plantData['\$id'];

                // Skip rendering if the plant data is missing the ID.
                if (plantId == null) {
                  print(
                      "Warning: Favorite plant data missing '\$id'. Index: $index");
                  return const SizedBox.shrink();
                }

                // Get the localized plant name.
                final String localizedName =
                    getLocalizedValue(context, plantData, 'Name');

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
                    // Navigate to the Plant Detail Screen when the card is tapped.
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
                                  // Display the plant image if available.
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      // Loading builder for the image.
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
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
                                      // Error builder for the image.
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
                                  // Show a placeholder icon if no image is available.
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

                          Expanded(
                            child: Text(
                              localizedName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Favorite Icon Button
                          // Button to remove the plant from favorites.
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28,
                            ),
                            // --- Use localized tooltip from .arb template ---
                            tooltip: l10n
                                .removeFromFavoritesTooltip, // Localized tooltip.
                            visualDensity: VisualDensity.standard,
                            // Call the unfavorite handler when the button is pressed.
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

  // Builds a list of placeholder cards while favorite plant details are loading.
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
