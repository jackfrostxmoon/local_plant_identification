//Import all the necessary packages and files.
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/gallery/gallery_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations for localization.

/// Displays a card containing links to the Media/Gallery and Dashboard sections.
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme for styling.
    // Get the AppLocalizations instance for accessing localized strings.
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align children to the start (left).
      children: [
        // Localized title for the Media section.
        Text(l10n.mediaTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8), // Space below the title.
        Card(
          elevation: 2, // Add a slight shadow to the card.
          clipBehavior: Clip.antiAlias, // Ensures content is clipped correctly.
          // Use a Column to arrange the ListTiles vertically.
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Make the column take minimum vertical space.
            children: [
              // ListTile for navigating to the Gallery Screen.
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined, // Icon for the gallery.
                  color: theme.colorScheme.primary, // Icon color from theme.
                ),
                title: Text(
                    l10n.galleryLabel), // Localized text for the gallery link.
                onTap: () {
                  // Navigate to the GalleryScreen when the tile is tapped.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GalleryScreen()),
                  );
                },
              ),
              // Divider line between the ListTiles.
              const Divider(height: 1, indent: 16, endIndent: 16),
              // ListTile for navigating to the Dashboard Screen.
              ListTile(
                leading: Icon(
                  Icons.dashboard_outlined, // Icon for the dashboard.
                  color: theme.colorScheme.primary, // Icon color from theme.
                ),
                title: Text(l10n
                    .dashboardLabel), // Localized text for the dashboard link.
                onTap: () {
                  // Navigate to the Dashboard, clearing all previous routes from the stack.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard', // The named route for the dashboard.
                    (Route<dynamic> route) =>
                        false, // This predicate removes all routes below the new route.
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
