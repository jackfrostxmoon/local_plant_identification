import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';

// --- Localization Helper Function ---
// NOTE: Ideally, move this to a separate utility file (e.g., utils/localization_helper.dart)
// and import it here and in PlantDetailScreen.dart.
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
// --- End Localization Helper Function ---

/// Displays a single plant item with image, divider, and localized name. Clickable.
class PlantItemCard extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantItemCard({required this.plant, super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localized name using the helper function
    final String localizedName = _getLocalizedValue(
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
