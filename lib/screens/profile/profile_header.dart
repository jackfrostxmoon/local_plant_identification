import 'package:flutter/material.dart';

/// Displays the user's avatar, name/username, and email.
class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoURL; // Optional: Add for user image

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Determine if photoURL is valid
    final bool hasImage = photoURL != null && photoURL!.isNotEmpty;

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: colorScheme.secondaryContainer,
            // Display image if available, otherwise icon
            backgroundImage: hasImage ? NetworkImage(photoURL!) : null,
            child:
                !hasImage
                    ? Icon(
                      Icons.person_outline,
                      size: 60,
                      color: colorScheme.onSecondaryContainer,
                    )
                    : null, // No child needed if backgroundImage is set
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
