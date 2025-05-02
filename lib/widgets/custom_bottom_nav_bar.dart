import 'package:flutter/material.dart';
// Import the AppLocalizations class
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the AppLocalizations instance
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home), // Changed from home
          // Use localized string for the label
          label: l10n.bottomNavDashboard,
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            // Use localized string for the label
            label: l10n.bottomNavSearch),
        BottomNavigationBarItem(
          icon: const Icon(Icons.camera_alt),
          // Use localized string for the label
          label: l10n.bottomNavCamera,
        ), // Changed from camera
        BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            // Use localized string for the label
            label: l10n.bottomNavFavourite),
        BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            // Use localized string for the label
            label: l10n.bottomNavProfile),
      ],
      currentIndex: currentIndex, // Use the passed-in index
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: onTap, // Use the passed-in callback function
      type: BottomNavigationBarType.fixed, // Keep type fixed
      showUnselectedLabels: true, // Optional: Ensure labels are always shown
      showSelectedLabels: true, // Optional: Ensure labels are always shown
    );
  }
}
