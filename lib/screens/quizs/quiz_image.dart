// lib/widgets/quiz_image.dart
import 'package:flutter/material.dart';

class QuizImage extends StatelessWidget {
  final String? imageUrl;

  const QuizImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      height: 200, // Define a fixed height for the image container
      width: 200, // Define a fixed width to make it square
      decoration: BoxDecoration(
        color: Colors.white, // Placeholder background
        borderRadius: BorderRadius.circular(15.0), // Rounded corners
      ),
      child: ClipRRect(
        // Clip the child (Image or Icon) to the rounded corners
        borderRadius: BorderRadius.circular(15.0),
        child:
            hasImage
                ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover, // Cover the container
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print("Image Load Error: $error"); // Log error
                    // Show placeholder icon on error
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined, // Placeholder icon
                        color: Colors.black54, // Adjusted color
                        size: 80,
                      ),
                    );
                  },
                )
                : const Center(
                  // Show placeholder icon if no image URL
                  child: Icon(
                    Icons.image_outlined, // Generic image placeholder icon
                    color: Colors.white, // Adjusted color
                    size: 80,
                  ),
                ),
      ),
    );
  }
}
