import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:local_plant_identification/services/appwrite_service.dart'; // Adjust import

// A single tile widget to display an image in the gallery grid.
class ImageGridTile extends StatelessWidget {
  // The unique ID of the image file in Appwrite storage.
  final String imageId;
  // An instance of the AppwriteService to interact with Appwrite.
  final AppwriteService appwriteService;
  // A flag indicating if a deletion operation is currently in progress.
  final bool isDeleting;
  // Callback function to be called when the delete button is pressed.
  final Function(String) onDeleteImage; // Callback to trigger deletion

  // Constructor for the ImageGridTile widget.
  const ImageGridTile({
    super.key,
    required this.imageId,
    required this.appwriteService,
    required this.isDeleting,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    // FutureBuilder to asynchronously fetch the image data.
    return FutureBuilder<Uint8List>(
      // Fetch image data using the provided service and ID.
      future: appwriteService.storage.getFileDownload(
        bucketId: AppwriteConfig.plantImagesStorageId, // Assuming global config
        fileId: imageId,
      ),
      // Builder function to handle the state of the future.
      builder: (context, snapshot) {
        // --- Loading State ---
        // Show a loading indicator while fetching the image data.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        // --- Error State ---
        // Show an error message if fetching the image data fails.
        else if (snapshot.hasError) {
          print("Error loading file download for $imageId: ${snapshot.error}");
          return Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.orange, size: 30),
                const SizedBox(height: 4),
                Text(
                  'Load Error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange.shade900, fontSize: 10),
                ),
              ],
            ),
          );
        }
        // --- Success State ---
        // Display the image if the data is successfully fetched and is not empty.
        else if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          final imageData = snapshot.data!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // --- Tappable Image for Full View ---
                // Wrap the image in an InkWell to make it tappable for viewing.
                InkWell(
                  onTap: () => _showImageDialog(context, imageData),
                  child: Image.memory(
                    imageData,
                    fit: BoxFit.cover,
                    // Error builder to handle cases where the image cannot be displayed.
                    errorBuilder: (context, error, stackTrace) {
                      print("Error displaying image data for $imageId: $error");
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // --- Delete Button ---
                // Position the delete button in the top-right corner.
                Positioned(
                  top: 6.0,
                  right: 6.0,
                  child: Tooltip(
                    message: 'Delete Image',
                    preferBelow: false,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          // Disable tap if deletion is in progress
                          // Call the onDeleteImage callback when tapped, if not deleting.
                          onTap:
                              isDeleting ? null : () => onDeleteImage(imageId),
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        // --- Empty/Invalid Data State ---
        // Show a placeholder icon if no image data is received or it's empty.
        else {
          print("No file data received for $imageId (Data: ${snapshot.data})");
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
        }
      },
    );
  }

  // Helper method to show the image in a dialog for full view and zooming.
  void _showImageDialog(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            // InteractiveViewer allows zooming and panning of the image.
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(imageData, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
