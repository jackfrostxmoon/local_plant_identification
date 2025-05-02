import 'package:flutter/material.dart';

// A widget to display the image associated with a quiz question.
class QuizImage extends StatelessWidget {
  final String? imageUrl; // The URL of the image to display (nullable).

  // Constructor for the QuizImage widget.
  const QuizImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Check if an image URL is provided and is not empty.
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      height: 200, // Define a fixed height for the image container.
      width: 200, // Define a fixed width to make it square.
      decoration: BoxDecoration(
        color: Colors.white, // Placeholder background color.
        borderRadius: BorderRadius.circular(
            15.0), // Apply rounded corners to the container.
      ),
      child: ClipRRect(
        // Clip the child (Image or Icon) to the container's rounded corners.
        borderRadius: BorderRadius.circular(15.0),
        child: hasImage
            ? Image.network(
                imageUrl!, // Display the image from the provided URL.
                fit: BoxFit
                    .cover, // Cover the container while maintaining aspect ratio.
                // Builder function to show a loading indicator while the image is loading.
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // Show the image once loading is complete.
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent, // Color of the loading spinner.
                    ),
                  );
                },
                // Builder function to handle errors during image loading.
                errorBuilder: (context, error, stackTrace) {
                  print(
                      "Image Load Error: $error"); // Log the error for debugging.
                  // Show a placeholder icon if there's an error loading the image.
                  return const Center(
                    child: Icon(
                      Icons
                          .image_not_supported_outlined, // Placeholder icon indicating image not supported or failed.
                      color: Colors.black54, // Adjusted icon color.
                      size: 80, // Size of the icon.
                    ),
                  );
                },
              )
            : const Center(
                // Show a generic placeholder icon if no image URL is provided.
                child: Icon(
                  Icons.image_outlined, // Generic image placeholder icon.
                  color: Colors.white, // Adjusted icon color.
                  size: 80, // Size of the icon.
                ),
              ),
      ),
    );
  }
}
