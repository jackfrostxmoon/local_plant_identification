// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/camera/camera_screen.dart';
import 'package:local_plant_identification/screens/favourite/favorites_screen.dart';
import 'package:local_plant_identification/screens/profile/user_profile_screen.dart';
import 'package:local_plant_identification/screens/search/plant_search_screen.dart';
import 'package:local_plant_identification/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:local_plant_identification/widgets/localization_helper.dart';
import 'package:local_plant_identification/widgets/custom_logout_button.dart';

import 'dashboard_content_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Widget options remain the same
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardContentScreen(),
    const PlantSearchScreen(),
    const CameraScreen(),
    const FavoritesScreen(),
    const UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- Use AppLocalizations for titles ---
  List<String> _getAppBarTitles(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return <String>[
      l10n.dashboardAppBarTitle, // Localized
      l10n.searchAppBarTitle, // Localized
      l10n.cameraAppBarTitle, // Localized
      l10n.favoritesAppBarTitle, // Localized
      l10n.profileAppBarTitle, // Localized
    ];
  }
  // --- End localized titles ---

  @override
  Widget build(BuildContext context) {
    // Get the localized titles based on the current context
    final appBarTitles = _getAppBarTitles(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA8E6A2),
        // Use the localized title based on the selected index
        title: Text(appBarTitles[_selectedIndex]),
        actions: const [
          // Use the extracted widgets
          LanguageSelectionMenu(),
          LogoutButton(),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
