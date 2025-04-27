// screens/favourite/favorites_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/screens/favourite/favorites_utils.dart';

// Import your Plant Detail Screen and the Appwrite Service
import '../plant_configs/plant_detail_screen.dart' as detail_screen;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final String? userId =
      detail_screen.getCurrentUserId(); // Use function from utils
  final AppwriteService _appwriteService = AppwriteService();

  // --- Helper Function _fetchFavoritePlantDetails (Keep as is) ---
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
      final List<Map<String, dynamic>> plantDetails =
          results
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
      rethrow;
    }
  }
  // --- End Helper Function ---

  // --- Helper Function to Handle Unfavorite Action (Keep as is) ---
  Future<void> _handleUnfavorite(String plantId, String plantName) async {
    try {
      await removeFavoritePlant(plantId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$plantName removed from favorites.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error removing favorite from list: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing $plantName: ${e.toString()}'),
            backgroundColor: Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  // --- End Helper Function ---

  @override
  Widget build(BuildContext context) {
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
    return _buildFavoritesList();
  }

  Widget _buildFavoritesList() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
      builder: (context, userSnapshot) {
        // ... (Connection state, error, empty checks remain the same) ...
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError) {
          print("Firestore Error: ${userSnapshot.error}");
          return const Center(
            child: Text(
              'Error loading favorites list.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
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
          return const Center(
            child: Text(
              'You have no favorite plants yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchFavoritePlantDetails(favoritePlantIds),
          builder: (context, plantDetailsSnapshot) {
            // ... (Connection state, error, empty checks remain the same) ...
            if (plantDetailsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildLoadingPlaceholders(favoritePlantIds.length);
            }
            if (plantDetailsSnapshot.hasError) {
              print("Appwrite Fetch Error: ${plantDetailsSnapshot.error}");
              return Center(
                child: Text(
                  'Error loading plant details: ${plantDetailsSnapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!plantDetailsSnapshot.hasData) {
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
              return const Center(
                child: Text(
                  'You have no favorite plants yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

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
                  return const SizedBox.shrink();
                }

                final String name = plantData['Name'] ?? 'Unknown Plant';
                final String? imageUrl = plantData['image'];

                // --- Card Layout with Increased Size ---
                return Card(
                  // --- Increased vertical margin ---
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      16.0,
                    ), // Slightly larger radius
                  ),
                  elevation: 3, // Slightly more elevation
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => detail_screen.PlantDetailScreen(
                                plantData: plantData,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      // --- Increased internal padding ---
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // --- Image Area (Doubled Size) ---
                          SizedBox(
                            width: 100, // Increased width
                            height: 100, // Increased height
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                12.0,
                              ), // Larger radius
                              child:
                                  (imageUrl != null && imageUrl.isNotEmpty)
                                      ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height:
                                                    24, // Keep indicator size reasonable
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.grey[500],
                                              size: 40, // Slightly larger icon
                                            ),
                                          );
                                        },
                                      )
                                      : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: Colors.grey[500],
                                          size: 40, // Slightly larger icon
                                        ),
                                      ),
                            ),
                          ),
                          // --- Increased spacing ---
                          const SizedBox(width: 16),

                          // --- Text Area (Name) ---
                          Expanded(
                            child: Text(
                              name,
                              // --- Slightly larger font ---
                              style: const TextStyle(
                                fontSize: 18, // Increased font size
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3, // Allow more wrapping
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // --- Increased spacing ---
                          const SizedBox(width: 12),

                          // --- Favorite Icon Button ---
                          IconButton(
                            // --- Larger icon ---
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28, // Increased icon size
                            ),
                            tooltip: 'Remove from favorites',
                            visualDensity:
                                VisualDensity
                                    .standard, // Reset density if needed
                            // padding: EdgeInsets.zero, // Keep padding zero
                            // constraints: const BoxConstraints(), // Keep constraints
                            onPressed: () {
                              _handleUnfavorite(plantId, name);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                // --- End Card Layout ---
              },
            );
          },
        );
      },
    );
  }

  // --- Updated Placeholder widget ---
  Widget _buildLoadingPlaceholders(int count) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      itemCount: count,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8.0,
          ), // Match increased margin
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Match increased radius
          ),
          elevation: 3, // Match increased elevation
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Match increased padding
            child: Row(
              children: [
                // Image Placeholder (Larger)
                Container(
                  width: 100, // Match increased size
                  height: 100, // Match increased size
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Match increased radius
                  ),
                ),
                const SizedBox(width: 16), // Match increased spacing
                // Text Placeholder (Larger)
                Expanded(
                  child: Column(
                    // Use column for potentially multi-line text placeholder
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, color: Colors.grey[300]),
                      const SizedBox(height: 6),
                      Container(
                        height: 20,
                        width: 100,
                        color: Colors.grey[300],
                      ), // Simulate second line
                    ],
                  ),
                ),
                const SizedBox(width: 12), // Match increased spacing
                // Icon Placeholder (Larger)
                Icon(
                  Icons.favorite_border,
                  color: Colors.grey[300],
                  size: 28,
                ), // Match increased size
              ],
            ),
          ),
        );
      },
    );
  }
}
