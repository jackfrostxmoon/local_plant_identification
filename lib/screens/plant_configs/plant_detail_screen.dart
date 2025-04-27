import 'dart:async'; // Import for StreamSubscription

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// Assuming these functions are defined elsewhere and imported correctly
// import 'path/to/your/favorites_utils.dart'; // Example import

// --- Placeholder implementations for demonstration ---
// Ensure these are defined or imported correctly in your actual project
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
// --- End Placeholder implementations ---

// --- PASTE THE _getLocalizedValue function HERE if not in a separate file ---
String _getLocalizedValue(
  BuildContext context,
  Map<String, dynamic> data,
  String baseKey,
) {
  final locale = Localizations.localeOf(context);
  final langCode = locale.languageCode; // 'en', 'ms', 'zh', etc.

  String localeKey;
  switch (langCode) {
    case 'ms': // Malay
      localeKey = '${baseKey}_MS';
      break;
    case 'zh': // Chinese
      localeKey = '${baseKey}_ZH';
      break;
    default: // Default to English or if locale is 'en'
      localeKey = baseKey;
      break;
  }

  // 1. Try fetching the locale-specific value
  if (data.containsKey(localeKey) &&
      data[localeKey] != null &&
      data[localeKey].toString().isNotEmpty) {
    return data[localeKey].toString();
  }

  // 2. Fallback to the base (English) value if locale-specific is missing/empty
  if (data.containsKey(baseKey) &&
      data[baseKey] != null &&
      data[baseKey].toString().isNotEmpty) {
    return data[baseKey].toString();
  }

  // 3. Fallback if even the base value is missing/empty
  return 'N/A'; // Or return baseKey, or 'Unknown', etc.
}
// --- End helper function ---

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

    // Show loading state immediately for responsiveness
    // Note: Firestore listener will update the final state
    // setState(() {
    //   _isLoadingFavorite = true; // Optional: show loader during toggle
    // });

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
        // Revert loading state if toggle failed and listener didn't update
        // setState(() {
        //   _isLoadingFavorite = false;
        // });
      }
    }
  }

  // --- MODIFIED Helper to build attribute row using localization ---
  Widget _buildAttributeRow(
    BuildContext context,
    String label,
    String baseKey,
  ) {
    // Use the helper function to get the localized value based on the baseKey
    final String localizedValue = _getLocalizedValue(
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
            label, // Label remains the same (could also be localized if needed)
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
    final String localizedName = _getLocalizedValue(
      context,
      widget.plantData,
      'Name',
    );

    // Extract image URL (doesn't need localization)
    final String? imageUrl = widget.plantData['image'];

    // Determine icon based on loading and favorite state (unchanged)
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

          // --- MODIFIED: Display Attributes using the helper and base keys ---
          _buildAttributeRow(context, 'Name', 'Name'),
          _buildAttributeRow(context, 'Description', 'Description'),
          _buildAttributeRow(context, 'Growth Habit', 'Growth_Habit'),
          _buildAttributeRow(context, 'Interesting Fact', 'Interesting_fact'),
          _buildAttributeRow(
            context,
            'Toxicity (Humans & Pets)',
            'Toxicity_Humans_and_Pets',
          ),

          // --- End Modified Attributes ---
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
