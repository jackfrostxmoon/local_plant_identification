import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/screens/favourite/favorites_utils.dart';
// Remove FirebaseAuth import if getCurrentUserId is moved
// import 'package:firebase_auth/firebase_auth.dart';

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
    // ... (previous implementation remains the same) ...
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

  // --- Helper Function to Handle Unfavorite Action ---
  Future<void> _handleUnfavorite(String plantId, String plantName) async {
    try {
      await removeFavoritePlant(plantId); // Call the function from utils
      // Optional: Show a confirmation SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$plantName removed from favorites.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // No need for setState, StreamBuilder will handle the update
    } catch (e) {
      print("Error removing favorite from list: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing $plantName: ${e.toString()}'),
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
      // ... (login prompt remains the same) ...
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Favorites'),
          backgroundColor: const Color(0xFFA8E6A2),
        ),
        body: const Center(
          child: Text('Please log in to see your favorite plants.'),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
        builder: (context, userSnapshot) {
          // ... (Connection state and error handling remain the same) ...
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            print("Firestore Error: ${userSnapshot.error}");
            return const Center(child: Text('Error loading favorites list.'));
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(
              child: Text('You have no favorite plants yet.'),
            );
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          final List<dynamic> favoriteIdsDynamic =
              userData?['favoritePlantIds'] as List<dynamic>? ?? [];
          final List<String> favoritePlantIds =
              favoriteIdsDynamic.map((id) => id.toString()).toList();

          if (favoritePlantIds.isEmpty) {
            return const Center(
              child: Text('You have no favorite plants yet.'),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchFavoritePlantDetails(favoritePlantIds),
            builder: (context, plantDetailsSnapshot) {
              // ... (Connection state and error handling remain the same) ...
              if (plantDetailsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (plantDetailsSnapshot.hasError) {
                print("Appwrite Fetch Error: ${plantDetailsSnapshot.error}");
                return Center(
                  child: Text(
                    'Error loading plant details: ${plantDetailsSnapshot.error}',
                  ),
                );
              }
              if (!plantDetailsSnapshot.hasData) {
                return const Center(
                  child: Text('Could not load details for favorite plants.'),
                );
              }
              final List<Map<String, dynamic>> favoritePlants =
                  plantDetailsSnapshot.data!;

              if (favoritePlants.isEmpty && favoritePlantIds.isNotEmpty) {
                return const Center(
                  child: Text(
                    'Could not find details for saved favorites. They may have been removed.',
                  ),
                );
              }
              if (favoritePlants.isEmpty) {
                return const Center(
                  child: Text('You have no favorite plants yet.'),
                );
              }

              // *** MODIFIED ListView.builder ***
              return ListView.builder(
                itemCount: favoritePlants.length,
                itemBuilder: (context, index) {
                  final plantData = favoritePlants[index];
                  final String? plantId = plantData['\$id'];

                  if (plantId == null) {
                    print(
                      "Warning: Favorite plant data missing '\$id'. Skipping item.",
                    );
                    return const SizedBox.shrink();
                  }

                  final String name = plantData['Name'] ?? 'Unknown Plant';
                  final String? imageUrl = plantData['image'];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading:
                          (imageUrl != null && imageUrl.isNotEmpty)
                              ? ClipRRect(
                                /* ... (Image loading remains the same) ... */
                                borderRadius: BorderRadius.circular(4.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                              : const Icon(Icons.local_florist, size: 50),
                      title: Text(name),
                      // Optional: Keep subtitle or remove it
                      // subtitle: Text('ID: $plantId'),

                      // *** NEW: Trailing unfavorite button ***
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.favorite, // Filled heart icon
                          color: Colors.red, // Color to indicate it's favorited
                        ),
                        tooltip: 'Remove from favorites',
                        onPressed: () {
                          // Call the helper function to handle removal
                          _handleUnfavorite(plantId, name);
                        },
                      ),

                      // *** END NEW ***

                      // Keep onTap for navigation to detail screen
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
                    ),
                  );
                },
              );
              // *** END MODIFIED ListView.builder ***
            },
          );
        },
      ),
    );
  }
}
