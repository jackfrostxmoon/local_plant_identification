// widgets/media_card.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/gallery/gallery_screen.dart';
// --- Import AppLocalizations ---
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Displays the card for the Media/Gallery section.
class MediaCard extends StatelessWidget {
  // Removed onViewGallery as it wasn't used in the original build method
  // Add it back if you intend to use it elsewhere.
  // final VoidCallback onViewGallery;

  const MediaCard({
    super.key,
    /* required this.onViewGallery */
  }); // Remove if not needed

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // --- Get AppLocalizations instance ---
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Localized Title ---
        Text(l10n.mediaTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(
              Icons.photo_library_outlined,
              color: theme.colorScheme.primary,
            ),
            // --- Localized Label ---
            title: Text(l10n.galleryLabel),
            onTap: () {
              // Navigation logic remains the same
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GalleryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
