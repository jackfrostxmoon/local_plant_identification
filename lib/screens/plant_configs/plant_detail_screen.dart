import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_plant_identification/widgets/localization_helper.dart'
    as LocalizationHelper;

// Asynchronously adds a plant ID to the current user's favorite list in Firestore.
Future<void> addFavoritePlant(String plantId) async {
  final userId = getCurrentUserId(); // Get the current logged-in user's ID.
  if (userId == null) return; // Return if no user is logged in.
  final userDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId); // Get the document reference for the user.
  print(
      'Attempting to add favorite: $plantId for user $userId'); // Log the action.
  try {
    // Update the user's document to add the plantId to the 'favoritePlantIds' array.
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayUnion([
        plantId
      ]), // Use arrayUnion to add the ID if it's not already present.
    });
    print('Successfully added favorite.'); // Log success.
  } catch (e) {
    // Catch and handle any errors during the update.
    print("Error adding favorite: $e"); // Log the error.
    // Re-throw the exception after printing, allowing the caller to handle it further (e.g., show a snackbar).
    throw Exception("Error adding favorite: $e");
  }
}

// Asynchronously removes a plant ID from the current user's favorite list in Firestore.
Future<void> removeFavoritePlant(String plantId) async {
  final userId = getCurrentUserId(); // Get the current logged-in user's ID.
  if (userId == null) return; // Return if no user is logged in.
  final userDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId); // Get the document reference for the user.
  print(
      'Attempting to remove favorite: $plantId for user $userId'); // Log the action.
  try {
    // Update the user's document to remove the plantId from the 'favoritePlantIds' array.
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayRemove(
          [plantId]), // Use arrayRemove to remove the ID if it's present.
    });
    print('Successfully removed favorite.'); // Log success.
  } catch (e) {
    // Catch and handle any errors during the update.
    print("Error removing favorite: $e"); // Log the error.
    // Re-throw the exception after printing.
    throw Exception("Error removing favorite: $e");
  }
}

// Retrieves the UID of the currently logged-in Firebase user.
String? getCurrentUserId() {
  return FirebaseAuth.instance.currentUser
      ?.uid; // Return the UID or null if no user is logged in.
}

// A screen to display detailed information about a specific plant.
class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic>
      plantData; // The data map containing all plant information.

  // Constructor for the PlantDetailScreen.
  const PlantDetailScreen({required this.plantData, super.key});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  bool _isFavorited =
      false; // Flag indicating if the current plant is favorited by the user.
  bool _isLoadingFavorite =
      true; // Flag indicating if the favorite status is being loaded.
  StreamSubscription?
      _userDocSubscription; // Subscription to listen for changes in the user's Firestore document.
  String? _plantId; // The ID of the current plant.

  @override
  void initState() {
    super.initState();
    _plantId = widget
        .plantData['\$id']; // Extract the plant ID from the provided data.

    // If the plant ID is available, start listening to the user's favorite status.
    if (_plantId != null) {
      _listenToFavoriteStatus();
    } else {
      // Log an error if the plant ID is missing.
      print(
        "Error: Plant ID ('\$id') is missing from plantData in PlantDetailScreen.",
      );
      // Update the loading state if the widget is still mounted.
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userDocSubscription
        ?.cancel(); // Cancel the Firestore subscription to prevent memory leaks.
    super.dispose();
  }

  // Listens to changes in the current user's Firestore document to update the favorite status.
  void _listenToFavoriteStatus() {
    final userId = getCurrentUserId(); // Get the current user's ID.
    // If no user is logged in or plant ID is missing, update state and return.
    if (userId == null || _plantId == null) {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
          _isFavorited = false;
        });
      }
      return;
    }

    // Get the document reference for the current user in the 'users' collection.
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    _userDocSubscription
        ?.cancel(); // Cancel any existing subscription before creating a new one.

    // Subscribe to the user's document snapshots.
    _userDocSubscription = userDocRef.snapshots().listen(
      (snapshot) {
        // Check if the widget is still mounted before updating state.
        if (mounted) {
          bool currentlyFavorited = false;
          // Check if the snapshot exists and contains data.
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()
                as Map<String, dynamic>; // Cast the data to a map.
            final favoriteIds =
                data['favoritePlantIds']; // Get the list of favorite plant IDs.
            // Check if 'favoritePlantIds' is a list and if the current plant ID is in the list.
            if (favoriteIds is List && favoriteIds.contains(_plantId)) {
              currentlyFavorited = true;
            }
          }
          // Update the state only if the favorite status has changed or if it was previously loading.
          if (_isFavorited != currentlyFavorited || _isLoadingFavorite) {
            setState(() {
              _isFavorited = currentlyFavorited;
              _isLoadingFavorite = false;
            });
          }
        }
      },
      // Handle errors during the stream listening.
      onError: (error) {
        print("Error listening to favorite status: $error"); // Log the error.
        // Update the loading state if the widget is still mounted.
        if (mounted) {
          setState(() {
            _isLoadingFavorite = false;
          });
        }
      },
    );
  }

  // Toggles the favorite status of the current plant for the logged-in user.
  Future<void> _toggleFavorite() async {
    final userId = getCurrentUserId(); // Get the current user's ID.
    // Check for missing plant ID or if no user is logged in.
    if (_plantId == null || userId == null) {
      print(
          "Cannot toggle favorite: Missing plant ID or user not logged in."); // Log the reason.
      // Show a SnackBar if the user is not logged in.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to manage favorites.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return; // Exit the function.
    }
    try {
      // If the plant is currently favorited, remove it.
      if (_isFavorited) {
        await removeFavoritePlant(_plantId!); // Call the remove function.
        // Show a SnackBar indicating successful removal.
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
        // If the plant is not favorited, add it.
        await addFavoritePlant(_plantId!); // Call the add function.
        // Show a SnackBar indicating successful addition.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Plant added to favorites!',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor:
                  Color(0xFFA8E6A2), // Custom background color for success.
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Catch and handle any errors during the toggle operation.
      print("Error toggling favorite: $e"); // Log the error.
      // Show a SnackBar indicating an error occurred.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating favorite status.'),
            backgroundColor: Colors.grey, // Grey background for error.
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Helper method to build a row displaying a plant attribute with its localized label and value.
  Widget _buildAttributeRow(
    BuildContext context,
    String label, // The hardcoded label for the attribute (e.g., 'Name').
    String
        baseKey, // The base key used for localization in the plant data (e.g., 'Name').
  ) {
    // Use the localization helper function to get the localized value of the attribute.
    final String localizedValue = LocalizationHelper.getLocalizedValue(
      context, // Pass the BuildContext for locale information.
      widget.plantData, // Pass the plant data map.
      baseKey, // Specify the base key for localization.
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start (left).
        children: [
          // Display the attribute label with a bold and primary color style.
          Text(
            label, // Display the hardcoded label.
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4), // Small vertical space.
          // Display the localized attribute value.
          Text(
            localizedValue, // Display the result from the localization helper.
            style: Theme.of(context)
                .textTheme
                .bodyLarge, // Standard body text style.
          ),
          const Divider(
              height: 16), // Add a separator line after each attribute row.
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the localized name of the plant to use as the AppBar title.
    final String localizedName = LocalizationHelper.getLocalizedValue(
      context, // Pass the BuildContext.
      widget.plantData, // Pass the plant data.
      'Name', // Use 'Name' as the base key for the title.
    );

    // Extract the image URL from the plant data. Can be null or empty.
    final String? imageUrl = widget.plantData['image'];

    // Determine which favorite action icon to display based on loading and favorited status.
    Widget favoriteActionIcon;
    if (_isLoadingFavorite) {
      // Show a loading spinner if the favorite status is being loaded.
      favoriteActionIcon = Container(
        padding: const EdgeInsets.all(8.0),
        width: 40,
        height: 40,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      // Show the favorite icon based on the current favorite status.
      favoriteActionIcon = IconButton(
        icon: Icon(
          // Use a filled heart if favorited, outlined heart otherwise.
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          color: _isFavorited
              ? Colors.red
              : null, // Red color if favorited, default color otherwise.
        ),
        // Set the tooltip text based on the favorite status.
        tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
        onPressed: _toggleFavorite, // Call _toggleFavorite when pressed.
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizedName), // Use the localized plant name as the AppBar title.
        backgroundColor:
            const Color(0xFFA8E6A2), // Custom background color for the AppBar.
        actions: [
          // Display the favorite action icon only if the plant ID is available.
          if (_plantId != null) favoriteActionIcon
        ],
      ),
      body: ListView(
        children: [
          // Display the plant image if a URL is available.
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    12.0), // Rounded corners for the image.
                child: Image.network(
                  imageUrl, // Display the image from the URL.
                  height: 250, // Fixed height for the image.
                  width: double.infinity, // Take full width.
                  fit: BoxFit
                      .cover, // Cover the area while maintaining aspect ratio.
                  // Builder for showing loading progress.
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  // Builder for handling image loading errors.
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading image: $error"); // Log the error.
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image, // Broken image icon.
                              color: Colors.grey[600],
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image unavailable', // Text indicating image is unavailable.
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
            // Display a placeholder if no image URL is available.
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

          // Build rows for each localized attribute.
          _buildAttributeRow(context, 'Name', 'Name'),
          _buildAttributeRow(context, 'Description', 'Description'),
          _buildAttributeRow(context, 'Growth Habit', 'Growth_Habit'),
          _buildAttributeRow(context, 'Interesting Fact', 'Interesting_fact'),
          _buildAttributeRow(
            context,
            'Toxicity (Humans & Pets)',
            'Toxicity_Humans_and_Pets',
          ),

          const SizedBox(height: 20), // Space at the bottom of the list.
        ],
      ),
    );
  }
}
