// lib/widgets/plant_grid_item.dart
import 'package:flutter/material.dart';
// --- Import the localization helper ---
import 'package:local_plant_identification/widgets/localization_helper.dart'; // Ensure this path is correct

class PlantGridItem extends StatelessWidget {
  final Map<String, dynamic> plant;
  final VoidCallback onTap; // Callback for when the item is tapped

  const PlantGridItem({required this.plant, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    // --- Get the localized name using the helper ---
    // This line fetches the name based on current locale ('Name', 'Name_MS', 'Name_CN')
    final String localizedName = getLocalizedValue(
      context,
      plant, // The data map passed from PlantSearchScreen
      'Name', // The base key
    );
    // --- End localization ---

    final String? imageUrl = plant['image'];

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Image Area ---
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      )
                    : const Icon(
                        Icons.image, // Using a placeholder image icon
                        size: 48.0,
                        color: Colors.grey,
                      ),
              ),
            ),
            // --- Divider Line ---
            const Divider(height: 1, thickness: 1, color: Colors.black26),
            // --- Name Area ---
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: Text(
                // --- Use the localized name ---
                localizedName, // Displays the result from getLocalizedValue
                // --- End localization usage ---
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
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
