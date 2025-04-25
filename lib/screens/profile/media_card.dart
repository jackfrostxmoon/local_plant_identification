import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/gallery/gallery_screen.dart';

/// Displays the card for the Media/Gallery section.
class MediaCard extends StatelessWidget {
  final VoidCallback onViewGallery;

  const MediaCard({super.key, required this.onViewGallery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Media', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(
              Icons.photo_library_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
