import 'dart:async'; // Import for StreamSubscription

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:local_plant_identification/widgets/localization_helper.dart'
    as LocalizationHelper;

Future<void> addFavoritePlant(String plantId) async {
  final userId = getCurrentUserId();
  if (userId == null) return;
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
  print('Attempting to add favorite: $plantId for user $userId');
  try {
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayUnion([plantId]),
    });
    print('Successfully added favorite.');
  } catch (e) {
    print("Error adding favorite: $e");
    // Consider showing a snackbar to the user
    throw Exception("Error adding favorite: $e");
  }
}

Future<void> removeFavoritePlant(String plantId) async {
  final userId = getCurrentUserId();
  if (userId == null) return;
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
  print('Attempting to remove favorite: $plantId for user $userId');
  try {
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayRemove([plantId]),
    });
    print('Successfully removed favorite.');
  } catch (e) {
    print("Error removing favorite: $e");
    // Consider showing a snackbar to the user
    throw Exception("Error removing favorite: $e");
  }
}

String? getCurrentUserId() {
  return FirebaseAuth.instance.currentUser?.uid;
}

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plantData;

  const PlantDetailScreen({required this.plantData, super.key});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  bool _isFavorited = false;
  bool _isLoadingFavorite = true;
  StreamSubscription? _userDocSubscription;
  String? _plantId;

  @override
  void initState() {
    super.initState();
    _plantId = widget.plantData['\$id'];

    if (_plantId != null) {
      _listenToFavoriteStatus();
    } else {
      print(
        "Error: Plant ID ('\$id') is missing from plantData in PlantDetailScreen.",
      );
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }

  void _listenToFavoriteStatus() {
    final userId = getCurrentUserId();
    if (userId == null || _plantId == null) {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
          _isFavorited = false;
        });
      }
      return;
    }

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    _userDocSubscription?.cancel();

    _userDocSubscription = userDocRef.snapshots().listen(
      (snapshot) {
        if (mounted) {
          bool currentlyFavorited = false;
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data() as Map<String, dynamic>;
            final favoriteIds = data['favoritePlantIds'];
            if (favoriteIds is List && favoriteIds.contains(_plantId)) {
              currentlyFavorited = true;
            }
          }
          if (_isFavorited != currentlyFavorited || _isLoadingFavorite) {
            setState(() {
              _isFavorited = currentlyFavorited;
              _isLoadingFavorite = false;
            });
          }
        }
      },
      onError: (error) {
        print("Error listening to favorite status: $error");
        if (mounted) {
          setState(() {
            _isLoadingFavorite = false;
          });
        }
      },
    );
  }

  Future<void> _toggleFavorite() async {
    final userId = getCurrentUserId();
    if (_plantId == null || userId == null) {
      print("Cannot toggle favorite: Missing plant ID or user not logged in.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to manage favorites.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    try {
      if (_isFavorited) {
        await removeFavoritePlant(_plantId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plant removed from favorites'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await addFavoritePlant(_plantId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Plant added to favorites!',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Color(0xFFA8E6A2),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      // No need to manually setState here, the listener will handle it
    } catch (e) {
      print("Error toggling favorite: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating favorite status.'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildAttributeRow(
    BuildContext context,
    String label,
    String baseKey,
  ) {
    // Use the helper function to get the localized value based on the baseKey
    final String localizedValue = LocalizationHelper.getLocalizedValue(
      context,
      widget.plantData,
      baseKey,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            localizedValue, // Display the localized value
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 16), // Add a separator
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get localized name for the AppBar title
    final String localizedName = LocalizationHelper.getLocalizedValue(
      context,
      widget.plantData,
      'Name',
    );

    // Extract image URL
    final String? imageUrl = widget.plantData['image'];

    Widget favoriteActionIcon;
    if (_isLoadingFavorite) {
      favoriteActionIcon = Container(
        padding: const EdgeInsets.all(8.0),
        width: 40,
        height: 40,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      favoriteActionIcon = IconButton(
        icon: Icon(
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          color: _isFavorited ? Colors.red : null,
        ),
        tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
        onPressed: _toggleFavorite,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedName), // Use localized name
        backgroundColor: const Color(0xFFA8E6A2),
        actions: [if (_plantId != null) favoriteActionIcon],
      ),
      body: ListView(
        children: [
          // Display Image (unchanged)
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading image: $error");
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey[600],
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image unavailable',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              height: 200,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 60,
                  color: Colors.grey[500],
                ),
              ),
            ),

          _buildAttributeRow(context, 'Name', 'Name'),
          _buildAttributeRow(context, 'Description', 'Description'),
          _buildAttributeRow(context, 'Growth Habit', 'Growth_Habit'),
          _buildAttributeRow(context, 'Interesting Fact', 'Interesting_fact'),
          _buildAttributeRow(
            context,
            'Toxicity (Humans & Pets)',
            'Toxicity_Humans_and_Pets',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
