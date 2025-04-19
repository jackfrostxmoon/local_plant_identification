import 'package:flutter/material.dart';

class FavouriteListItem extends StatelessWidget {
  final String imageUrl; // Placeholder, use actual image URL later
  final String title;
  final bool isFavourite;
  final VoidCallback onViewPressed;
  final VoidCallback onFavouritePressed;

  const FavouriteListItem({
    required this.imageUrl, // In real app, might be nullable
    required this.title,
    required this.isFavourite,
    required this.onViewPressed,
    required this.onFavouritePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Spacing between list items
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white, // Background for the item content
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            // 1. Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200], // Placeholder background
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black54),
              ),
              // Use Image.network if imageUrl is valid, otherwise show icon
              child:
                  imageUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.black54,
                              ),
                          loadingBuilder:
                              (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                        ),
                      )
                      : const Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: Colors.black54,
                      ),
            ),

            const SizedBox(width: 12), // Spacing
            // 2. Title (takes up available space)
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2, // Allow title to wrap slightly
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 12), // Spacing
            // 3. View Button
            ElevatedButton(
              onPressed: onViewPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800, // Dark grey background
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle: const TextStyle(fontSize: 14),
                minimumSize: const Size(0, 36), // Control button height
              ),
              child: const Text('View'),
            ),

            const SizedBox(width: 8), // Spacing
            // 4. Favourite Icon Button
            IconButton(
              icon: Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: isFavourite ? Colors.redAccent : Colors.black54,
              ),
              onPressed: onFavouritePressed,
              padding: EdgeInsets.zero, // Remove default padding
              constraints:
                  const BoxConstraints(), // Allow smaller tap area if needed
              tooltip:
                  isFavourite ? 'Remove from Favourites' : 'Add to Favourites',
            ),
          ],
        ),
      ),
    );
  }
}
