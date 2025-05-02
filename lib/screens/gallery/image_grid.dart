import 'package:flutter/material.dart';
import 'package:local_plant_identification/services/appwrite_service.dart'; // Adjust import
import 'image_grid_tile.dart'; // Import the new tile widget

// A widget that displays a grid of images from the user's gallery.
class ImageGrid extends StatelessWidget {
  // Flag to indicate if the images are currently being loaded.
  final bool isLoading;
  // The list of image IDs to display in the grid.
  final List<dynamic>
      imageIds; // Keep dynamic for initial Firestore flexibility
  // Flag to indicate if any image is currently being deleted.
  final bool isDeleting;
  // An instance of the AppwriteService to fetch image data.
  final AppwriteService appwriteService;
  // Callback function to trigger the deletion of an image.
  final Function(String) onDeleteImage;

  // Constructor for the ImageGrid widget.
  const ImageGrid({
    super.key,
    required this.isLoading,
    required this.imageIds,
    required this.isDeleting,
    required this.appwriteService,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if images are being loaded.
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show a message if the gallery is empty.
    if (imageIds.isEmpty) {
      return Center(
        child: Text(
          "Your gallery is empty.\nUpload some images!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    // Filter out invalid IDs before building the grid
    // Ensure that only valid string IDs are processed.
    final validImageIds = imageIds
        .where((id) => id is String && id.isNotEmpty)
        .map((id) => id as String)
        .toList();

    // Handle the case where the initial list had entries, but none were valid strings.
    if (validImageIds.isEmpty && imageIds.isNotEmpty) {
      // Handle case where Firestore might have invalid entries
      print("Warning: All image IDs in Firestore were invalid.");
      return Center(
        child: Text(
          "Error loading gallery items.\nPlease try refreshing.",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.red),
        ),
      );
    }

    // Build the grid view using GridView.builder for efficiency.
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      // Define the grid layout with a fixed number of columns.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns.
        crossAxisSpacing: 8, // Spacing between columns.
        mainAxisSpacing: 8, // Spacing between rows.
      ),
      itemCount: validImageIds.length, // The total number of items in the grid.
      // Builder function to create each grid tile.
      itemBuilder: (context, index) {
        final imageId = validImageIds[index];
        // Use the ImageGridTile widget to display each image.
        return ImageGridTile(
          key: ValueKey(imageId), // Add key for better performance
          imageId: imageId, // Pass the image ID.
          appwriteService:
              appwriteService, // Pass the Appwrite service instance.
          isDeleting: isDeleting, // Pass the deletion state.
          onDeleteImage: onDeleteImage, // Pass the delete callback.
        );
      },
    );
  }
}
