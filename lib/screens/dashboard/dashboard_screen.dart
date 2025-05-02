import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/camera/camera_screen.dart';
import 'package:local_plant_identification/screens/favourite/favorites_screen.dart';
import 'package:local_plant_identification/screens/profile/user_profile_screen.dart';
import 'package:local_plant_identification/screens/search/plant_search_screen.dart';
import 'package:local_plant_identification/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_plant_identification/widgets/custom_logout_button.dart';
import 'package:local_plant_identification/widgets/language_selection_menu.dart';
import 'dashboard_content_screen.dart';
import 'package:local_plant_identification/main.dart'; // Assuming 'cameras' is defined here

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab index

  // List of widgets corresponding to each tab in the bottom navigation bar
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize widget options here, especially if they depend on async data
    _widgetOptions = <Widget>[
      const DashboardContentScreen(),
      const PlantSearchScreen(),
      CameraScreen(cameras: cameras),
      const FavoritesScreen(),
      const UserProfileScreen(),
    ];
  }

  // Callback function for when a bottom navigation bar item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the state to reflect the new selection
    });
  }

  // Helper method to get localized AppBar titles based on the current context
  List<String> _getAppBarTitles(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Handle cases where localization might not be ready yet
    if (l10n == null) {
      // Return placeholder titles if localization isn't available
      return List.filled(5, 'Loading...');
    }
    // Return the list of localized titles for each screen
    return <String>[
      l10n.dashboardAppBarTitle,
      l10n.searchAppBarTitle,
      l10n.cameraAppBarTitle,
      l10n.favoritesAppBarTitle,
      l10n.profileAppBarTitle,
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Get the appropriate AppBar titles for the current locale
    final appBarTitles = _getAppBarTitles(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA8E6A2), // Custom AppBar color
        automaticallyImplyLeading: false, // Remove the default back button
        // Set the title based on the selected index, with a fallback for safety
        title: Text(
          _selectedIndex < appBarTitles.length
              ? appBarTitles[_selectedIndex]
              : 'Error', // Fallback title
        ),
        // Actions displayed on the right side of the AppBar
        actions: const [
          LanguageSelectionMenu(), // Widget for changing app language
          LogoutButton(), // Widget for user logout
        ],
      ),
      // IndexedStack efficiently displays only the widget corresponding to the
      // current index, while keeping the state of other widgets alive.
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      // Custom bottom navigation bar widget
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex, // Pass the current index
        onTap: _onItemTapped, // Pass the tap handler function
      ),
    );
  }
}
