import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';
import 'package:local_plant_identification/widgets/localization_helper.dart';

class PlantItemCard extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantItemCard({required this.plant, super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localized name using the helper function
    final String localizedName = getLocalizedValue(
      context, // Pass the BuildContext
      plant, // Pass the plant data map
      'Name', // Specify the base key for the name
    );

    // Wrap the Container with InkWell for tap detection
    return InkWell(
      onTap: () {
        // Navigate to the detail screen on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                // Pass the full plant data for the detail screen
                PlantDetailScreen(plantData: plant),
          ),
        );
        // Log using the localized name now
        print('Tapped on plant: $localizedName');
      },
      // Apply splash effect rounding consistent with the item's border
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 4.0),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        clipBehavior: Clip.antiAlias, // Ensures image respects border radius
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Area (No changes needed here)
            Expanded(
              child: Container(
                color: Colors.white, // Background for the image area
                child: (plant['image'] != null &&
                        plant['image'].toString().isNotEmpty)
                    ? Image.network(
                        plant['image'], // Use the image URL from the data
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          // Show placeholder icon while loading
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.black,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Show broken image icon on error
                          return const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: Colors.black,
                            ),
                          );
                        },
                      )
                    : const Center(
                        // Show placeholder if no image URL
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            // Separator Line (No changes needed here)
            const Divider(height: 1, thickness: 1, color: Colors.black),
            // Name Area (MODIFIED)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: const Color(0xFFCEE8D3), // Light green background
              child: Text(
                // Use the localizedName obtained from the helper function
                localizedName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
