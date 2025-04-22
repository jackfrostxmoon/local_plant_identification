import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/camera/camera_screen.dart';
import 'package:local_plant_identification/screens/favourite/favourite_screen.dart';
import 'package:local_plant_identification/screens/profile/user_profile_screen.dart';
import 'package:local_plant_identification/screens/search/search_screen.dart';
import 'package:local_plant_identification/widgets/custom_bottom_nav_bar.dart';
import 'dashboard_content_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Manages the selected tab index

  // List of widgets to display for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardContentScreen(), // Index 0
    SearchScreen(), // Index 1
    CameraScreen(), // Index 2 (assuming you have a CameraScreen widget)
    FavouriteScreen(), // Index 3
    UserProfileScreen(userId: '1'), // Index 4
  ];

  // Callback when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Optional: Define titles for each screen for the AppBar
  static const List<String> _appBarTitles = <String>[
    'Plant Explorer & Quiz',
    'Search Plants',
    'Camera',
    'Favourites',
    'User Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA8E6A2),
        title: Text(_appBarTitles[_selectedIndex]), // Title changes with tab
        actions: [
          // Conditionally show refresh only on the first tab
          if (_selectedIndex == 0)
            IconButton(
              tooltip: 'Refresh Plants',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // How to trigger refresh in DashboardContentScreen?
                // Option 1 (Simpler): Use RefreshIndicator inside DashboardContentScreen (as implemented above)
                // Option 2 (More complex): Use a GlobalKey to call _loadAllPlants
                // For Option 1, this button might not be strictly needed if pull-to-refresh is sufficient.
                // If you keep it, you'll need Option 2 (GlobalKey) or state management.
                // Let's comment it out assuming RefreshIndicator is preferred.
                // print("Refresh button in AppBar tapped - needs mechanism to call child");
              },
            ),
          // Keep logout action? Or move it entirely to UserScreen?
          // If kept here, it's always visible.
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add logout logic here
              print("Logout Tapped from AppBar");
              // Example: Navigator.pushReplacement(...) to login screen
            },
          ),
        ],
      ),
      // Use IndexedStack to preserve state of screens when switching tabs
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      // Use your custom bottom navigation bar
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
