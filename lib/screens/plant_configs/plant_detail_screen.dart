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

class PlantDetailScreen extends StatefulWidget {
  // Expecting the full data map for the selected plant FROM APPWRITE
  // IMPORTANT: Ensure this map includes the Appwrite Document ID, typically '$id'
  // and other keys like 'Name', 'Description', 'image', etc.
  final Map<String, dynamic> plantData;

  const PlantDetailScreen({required this.plantData, super.key});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  // State variables specific to this detail screen
  bool _isFavorited = false;
  bool _isLoadingFavorite =
      true; // To show loading indicator for the icon initially
  StreamSubscription? _userDocSubscription; // To listen for Firestore changes
  String? _plantId; // Store the Appwrite plant ID

  @override
  void initState() {
    super.initState();
    // Extract the Appwrite Document ID. Adjust '$id' if your key is different.
    _plantId = widget.plantData['\$id']; // Make sure '$id' is the correct key

    if (_plantId != null) {
      _listenToFavoriteStatus();
    } else {
      // Handle case where plant ID is missing - cannot favorite
      print(
        "Error: Plant ID ('\$id') is missing from plantData in PlantDetailScreen.",
      );
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
          // Optionally show an error message or disable button permanently
        });
      }
    }
  }

  @override
  void dispose() {
    _userDocSubscription
        ?.cancel(); // Cancel subscription to prevent memory leaks
    super.dispose();
  }

  // Listens to Firestore for changes in the user's favorites
  void _listenToFavoriteStatus() {
    final userId = getCurrentUserId();
    if (userId == null || _plantId == null) {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
          _isFavorited =
              false; // Can't be favorited if not logged in or no plant ID
        });
      }
      return;
    }

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    // Cancel any previous subscription
    _userDocSubscription?.cancel();

    _userDocSubscription = userDocRef.snapshots().listen(
      (snapshot) {
        if (mounted) {
          // Check if the widget is still in the tree
          bool currentlyFavorited = false;
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data() as Map<String, dynamic>;
            // Ensure 'favoritePlantIds' exists and is a list
            final favoriteIds = data['favoritePlantIds'];
            if (favoriteIds is List && favoriteIds.contains(_plantId)) {
              currentlyFavorited = true;
            }
          }
          // Update state only if the favorite status actually changed
          if (_isFavorited != currentlyFavorited || _isLoadingFavorite) {
            setState(() {
              _isFavorited = currentlyFavorited;
              _isLoadingFavorite = false; // Loading is complete
            });
          }
        }
      },
      onError: (error) {
        print("Error listening to favorite status: $error");
        if (mounted) {
          setState(() {
            _isLoadingFavorite = false;
            // Optionally show an error message
          });
        }
      },
    );
  }

  // Toggles the favorite status in Firestore
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

  // Helper to build a row for displaying an attribute
  Widget _buildAttributeRow(BuildContext context, String label, String? value) {
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
            value?.isNotEmpty ?? false
                ? value!
                : 'N/A', // Handle null or empty values
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 16), // Add a separator
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract data using the keys from your Appwrite attributes
    // Use widget.plantData here as we are in the State class
    final String name = widget.plantData['Name'] ?? 'Unknown Plant';
    final String? description = widget.plantData['Description'];
    final String? growthHabit = widget.plantData['Growth_Habit'];
    final String? interestingFact = widget.plantData['Interesting_fact'];
    final String? toxicity = widget.plantData['Toxicity_Humans_and_Pets'];
    // Ensure 'image' key exists and corresponds to your Appwrite storage setup
    final String? imageUrl = widget.plantData['image'];

    // Determine icon based on loading and favorite state
    Widget favoriteActionIcon;
    if (_isLoadingFavorite) {
      favoriteActionIcon = Container(
        padding: const EdgeInsets.all(8.0), // Padding for loader visibility
        width: 40, // Consistent size with IconButton
        height: 40,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      favoriteActionIcon = IconButton(
        icon: Icon(
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          color: _isFavorited ? Colors.red : null, // Make it red when favorited
        ),
        tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
        onPressed: _toggleFavorite, // Directly call the toggle function
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xFFA8E6A2), // Or your theme color
        actions: [
          // Only show button if we have a plant ID
          if (_plantId != null) favoriteActionIcon,
        ],
      ),
      // The body should be the content of the detail screen
      body: ListView(
        // Use ListView for scrollable content
        children: [
          // Display Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrl, // Assuming this is a direct URL from Appwrite Storage
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
                    print("Error loading image: $error"); // Log image errors
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
            // Placeholder if no image
            Container(
              height: 200,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined, // More specific icon
                  size: 60,
                  color: Colors.grey[500],
                ),
              ),
            ),

          // Display Attributes using the helper
          _buildAttributeRow(context, 'Name', name),
          _buildAttributeRow(context, 'Description', description),
          _buildAttributeRow(context, 'Growth Habit', growthHabit),
          _buildAttributeRow(context, 'Interesting Fact', interestingFact),
          _buildAttributeRow(context, 'Toxicity (Humans & Pets)', toxicity),

          const SizedBox(height: 20), // Add some padding at the bottom
        ],
      ),
    );
  }
}
