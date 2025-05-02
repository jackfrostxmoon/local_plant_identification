import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';
import 'package:local_plant_identification/widgets/localization_helper.dart'; // Import the localization helper.

// A widget to display a single plant item as a card in a horizontal list.
class PlantItemCard extends StatelessWidget {
  final Map<String, dynamic>
      plant; // Data map containing plant information, including localized names and image URL.

  // Constructor for the PlantItemCard.
  const PlantItemCard({required this.plant, super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localized name of the plant using the localization helper function.
    // This function finds the appropriate name based on the current locale (e.g., 'Name', 'Name_MS', 'Name_CN').
    final String localizedName = getLocalizedValue(
      context, // Pass the current BuildContext to access locale information.
      plant, // Pass the data map containing plant information.
      'Name', // Specify the base key used for the plant's name in the data map.
    );

    // Wrap the main container with InkWell to make it tappable and add a visual splash effect.
    return InkWell(
      onTap: () {
        // Navigate to the PlantDetailScreen when the card is tapped.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(
                plantData:
                    plant), // Pass the full plant data to the detail screen.
          ),
        );
        // Print a log message indicating which plant was tapped, using its localized name.
        print('Tapped on plant: $localizedName');
      },
      // Apply the splash effect with rounding consistent with the card's border radius.
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 140, // Fixed width for the card.
        margin: const EdgeInsets.only(
            right: 15), // Margin to the right for spacing in a horizontal list.
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black, width: 4.0), // Black border around the card.
          borderRadius: BorderRadius.circular(
              8.0), // Apply rounded corners to the container.
          color: Colors.white, // Background color of the card.
        ),
        clipBehavior: Clip
            .antiAlias, // Ensures that content (like the image) respects the border radius.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Stretch children horizontally to fill the width.
          children: [
            // Image Area: This section displays the plant's image or a placeholder.
            Expanded(
              child: Container(
                color: Colors.white, // White background for the image area.
                child: (plant['image'] != null &&
                        plant['image']
                            .toString()
                            .isNotEmpty) // Check if the 'image' key exists and its value is not empty.
                    ? Image.network(
                        plant[
                            'image'], // Use the image URL from the plant data.
                        fit: BoxFit
                            .cover, // Cover the container while maintaining aspect ratio.
                        // Builder function to show a loading indicator while the image loads.
                        loadingBuilder: (context, child, loadingProgress) {
                          // Show a placeholder icon if the image is still loading.
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: Icon(
                              Icons.image_outlined, // Placeholder icon.
                              size: 40,
                              color: Colors.black,
                            ),
                          );
                        },
                        // Builder function to handle errors during image loading.
                        errorBuilder: (context, error, stackTrace) {
                          // Show a broken image icon if the image fails to load.
                          return const Center(
                            child: Icon(
                              Icons.broken_image_outlined, // Broken image icon.
                              size: 40,
                              color: Colors.black,
                            ),
                          );
                        },
                      )
                    : const Center(
                        // Show a placeholder icon if no image URL is available.
                        child: Icon(
                          Icons
                              .image_outlined, // Generic image placeholder icon.
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            // Separator Line: A thin line to separate the image from the plant name.
            const Divider(height: 1, thickness: 1, color: Colors.black),
            // Name Area: Displays the localized name of the plant.
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0), // Vertical padding around the text.
              color: const Color(
                  0xFFCEE8D3), // Light green background for the name area.
              child: Text(
                // Use the localizedName obtained from the helper function.
                localizedName,
                textAlign: TextAlign.center, // Center the text horizontally.
                maxLines: 1, // Limit the text to a single line.
                overflow: TextOverflow
                    .ellipsis, // Show "..." if the text overflows the single line.
                style: const TextStyle(
                  fontWeight:
                      FontWeight.normal, // Normal font weight for the name.
                  color: Colors.black, // Black text color.
                  fontSize: 14, // Font size for the name.
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
