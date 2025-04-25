import 'package:flutter/material.dart';
import 'package:local_plant_identification/services/appwrite_service.dart'; // Adjust import
import 'image_grid_tile.dart'; // Import the new tile widget

class ImageGrid extends StatelessWidget {
  final bool isLoading;
  final List<dynamic>
  imageIds; // Keep dynamic for initial Firestore flexibility
  final bool isDeleting;
  final AppwriteService appwriteService;
  final Function(String) onDeleteImage;

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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
    final validImageIds =
        imageIds
            .where((id) => id is String && id.isNotEmpty)
            .map((id) => id as String)
            .toList();

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

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: validImageIds.length,
      itemBuilder: (context, index) {
        final imageId = validImageIds[index];
        // Use the ImageGridTile widget
        return ImageGridTile(
          key: ValueKey(imageId), // Add key for better performance
          imageId: imageId,
          appwriteService: appwriteService,
          isDeleting: isDeleting,
          onDeleteImage: onDeleteImage,
        );
      },
    );
  }
}
