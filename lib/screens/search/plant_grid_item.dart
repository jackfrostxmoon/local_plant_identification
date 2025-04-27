// lib/widgets/plant_grid_item.dart
import 'package:flutter/material.dart';

class PlantGridItem extends StatelessWidget {
  final Map<String, dynamic> plant;
  final VoidCallback onTap; // Callback for when the item is tapped

  const PlantGridItem({required this.plant, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    // Extract data safely
    final String name = plant['Name'] ?? 'Unknown';
    final String? imageUrl = plant['image'];
    // We don't need plantId here directly, as onTap handles the action

    return GestureDetector(
      onTap: onTap, // Use the provided callback
      child: Card(
        clipBehavior: Clip.antiAlias, // Clip the content to the card shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Make children fill width
          children: [
            // --- Image Area ---
            Expanded(
              // Image takes up the available space above the name
              child: Container(
                color: Colors.grey[200], // Background for placeholder/loading
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover, // Cover the area
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Smaller indicator for grid item
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Placeholder icon if image fails
                          return Icon(
                            Icons.image_not_supported_outlined,
                            size: 40, // Slightly smaller icon
                            color: Colors.grey[500],
                          );
                        },
                      )
                    :
                    // Placeholder icon if no image URL
                    Icon(
                        Icons.image_outlined, // Generic image placeholder
                        size: 40, // Slightly smaller icon
                        color: Colors.grey[500],
                      ),
              ),
            ),
            // --- Divider Line ---
            const Divider(height: 1, thickness: 1, color: Colors.black26),
            // --- Name Area ---
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0, // Add slight horizontal padding
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1, // Prevent name wrapping
                overflow: TextOverflow.ellipsis, // Add ellipsis if too long
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
