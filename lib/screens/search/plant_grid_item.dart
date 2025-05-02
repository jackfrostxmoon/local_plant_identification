import 'package:flutter/material.dart';
// Import the localization helper, assuming its path is correct
import 'package:local_plant_identification/widgets/localization_helper.dart';

// A widget to display a single plant item in a grid.
class PlantGridItem extends StatelessWidget {
  // Data map containing plant information, including localized names and image URL.
  final Map<String, dynamic> plant;
  // Callback function executed when the plant item is tapped.
  final VoidCallback onTap;

  // Constructor for the PlantGridItem.
  const PlantGridItem({required this.plant, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localized name of the plant using the localization helper.
    // This function takes the context, the plant data map, and the base key ('Name')
    // to find the appropriate name based on the current locale (e.g., 'Name', 'Name_MS', 'Name_CN').
    final String localizedName = getLocalizedValue(
      context, // Provides locale information
      plant, // The source data for localization
      'Name', // The base key to look for
    );

    // Extract the image URL from the plant data. Can be null or empty.
    final String? imageUrl = plant['image'];

    // GestureDetector is used to make the Card tappable.
    return GestureDetector(
      onTap: onTap, // Execute the onTap callback when tapped.
      child: Card(
        // Ensures that content like the image is clipped within the card's rounded corners.
        clipBehavior: Clip.antiAlias,
        // Defines the shape of the card, here with rounded corners.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Adds a shadow to the card for visual separation.
        elevation: 2,
        child: Column(
          // Stretches the children (image and text) horizontally to fill the card width.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expanded widget makes the image area take up available vertical space.
            Expanded(
              child: Container(
                // Background color for the image area, visible while loading or if no image.
                color: Colors.grey[200],
                child: (imageUrl != null &&
                        imageUrl
                            .isNotEmpty) // Check if image URL exists and is not empty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit
                            .cover, // Covers the container while maintaining aspect ratio.
                        // Builder function for handling errors during image loading.
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                              Icons.error); // Display an error icon on failure.
                        },
                        // Builder function for showing loading progress.
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // Show the image once loaded.
                          }
                          return const Center(
                              child:
                                  CircularProgressIndicator()); // Show a spinner while loading.
                        },
                      )
                    : const Icon(
                        Icons
                            .image, // Display a generic image icon if no image URL
                        size: 48.0,
                        color: Colors.grey,
                      ),
              ),
            ),
            // A thin horizontal line to separate the image from the text.
            const Divider(height: 1, thickness: 1, color: Colors.black26),
            // Padding around the text area for spacing.
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: Text(
                // Display the localized plant name obtained earlier.
                localizedName,
                textAlign: TextAlign
                    .center, // Center the text horizontally within the padding.
                maxLines: 1, // Limit the text to a single line.
                overflow: TextOverflow
                    .ellipsis, // Show "..." if the text overflows the single line.
                style: const TextStyle(
                  fontWeight: FontWeight.w500, // Semi-bold font weight.
                  fontSize: 14, // Font size for the plant name.
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
