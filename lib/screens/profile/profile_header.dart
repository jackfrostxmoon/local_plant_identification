import 'package:flutter/material.dart';

/// Displays the user's avatar, name/username, and email in a centered column.
class ProfileHeader extends StatelessWidget {
  final String displayName; // The name or username to display.
  final String email; // The user's email address.
  final String?
      photoURL; // Optional: URL of the user's profile photo (nullable).

  // Constructor for the ProfileHeader widget.
  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.photoURL, // photoURL is optional.
  });

  @override
  Widget build(BuildContext context) {
    // Get the text theme and color scheme from the current theme.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Determine if a valid photo URL is provided.
    final bool hasImage = photoURL != null && photoURL!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Center the column's children vertically.
        crossAxisAlignment: CrossAxisAlignment
            .center, // Center the column's children horizontally.
        children: [
          // Display the user's avatar in a circle.
          CircleAvatar(
            radius: 60, // Set the radius of the circle avatar.
            backgroundColor: colorScheme
                .secondaryContainer, // Background color for the avatar.
            // Display the user's image if available, otherwise use a fallback icon.
            backgroundImage: hasImage
                ? NetworkImage(photoURL!)
                : null, // Use NetworkImage if photoURL exists.
            child: !hasImage
                ? Icon(
                    Icons.person_outline, // Placeholder icon if no image.
                    size: 60, // Size of the icon.
                    color: colorScheme
                        .onSecondaryContainer, // Icon color from theme.
                  )
                : null, // No child widget is needed if an image is being displayed.
          ),
          const SizedBox(height: 16), // Vertical space below the avatar.
          // Display the user's display name.
          Text(
            displayName, // The name or username.
            style: textTheme.headlineSmall, // Text style for the display name.
            textAlign: TextAlign.center, // Center the text.
          ),
          const SizedBox(height: 4), // Vertical space below the display name.
          // Display the user's email address.
          Text(
            email, // The user's email.
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.secondary, // Text color from theme.
            ),
            textAlign: TextAlign.center, // Center the text.
          ),
        ],
      ),
    );
  }
}
