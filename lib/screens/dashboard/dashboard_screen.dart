// screens/dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/camera/camera_screen.dart';
import 'package:local_plant_identification/screens/favourite/favorites_screen.dart';
import 'package:local_plant_identification/screens/profile/user_profile_screen.dart';
// Import the new search screen
import 'package:local_plant_identification/screens/search/plant_search_screen.dart';
// Remove the old placeholder import if it exists
// import 'package:local_plant_identification/screens/search/search_screen.dart';
import 'package:local_plant_identification/widgets/custom_bottom_nav_bar.dart';
import 'dashboard_content_screen.dart';

// Placeholder for User class if not imported
class User {
  final String id;
  User({required this.id});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Use the new PlantSearchScreen
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardContentScreen(), // Index 0
    const PlantSearchScreen(), // Index 1 - UPDATED
    const CameraScreen(), // Index 2
    const FavoritesScreen(), // Index 3
    const UserProfileScreen(), // Index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<String> _appBarTitles = <String>[
    'Plant Explorer & Quiz',
    'Search Plants', // Title for the search screen
    'Camera',
    'My Favourites',
    'User Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA8E6A2),
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          // ... (keep existing actions: language, logout)
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String value) {
              print('Language selected: $value');
              // Add language change logic here
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'en',
                  child: Text('English'),
                ),
                const PopupMenuItem<String>(value: 'ms', child: Text('Malay')),
                const PopupMenuItem<String>(
                  value: 'zh',
                  child: Text('Chinese'),
                ),
              ];
            },
          ),

          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // Use pushNamedAndRemoveUntil for better navigation stack management on logout
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              }
            },
          ),
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
