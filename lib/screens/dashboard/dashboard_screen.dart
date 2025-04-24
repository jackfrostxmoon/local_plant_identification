import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/camera/camera_screen.dart';
import 'package:local_plant_identification/screens/favourite/favorites_screen.dart';
import 'package:local_plant_identification/screens/profile/user_profile_screen.dart';
// Assuming User class is defined elsewhere, e.g.:
// class User { final String id; const User({required this.id}); }
import 'package:local_plant_identification/screens/search/search_screen.dart';
import 'package:local_plant_identification/widgets/custom_bottom_nav_bar.dart';
import 'dashboard_content_screen.dart';

// Placeholder for User class if not imported
class User {
  final String id;
  // Make constructor const if UserProfileScreen requires a const User
  // const User({required this.id});
  // Or keep it non-const if UserProfileScreen doesn't need const
  User({required this.id});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Manages the selected tab index

  // List of widgets to display for each tab
  // FIX: Changed 'const' to 'final' because widget instances are not compile-time constants
  static final List<Widget> _widgetOptions = <Widget>[
    DashboardContentScreen(), // Index 0
    SearchScreen(), // Index 1
    CameraScreen(), // Index 2 (assuming you have a CameraScreen widget)
    FavoritesScreen(), // Index 3
    UserProfileScreen(), // Index 4 - Add this line
  ];

  // Callback when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Optional: Define titles for each screen for the AppBar
  // This can remain const as String literals are constants
  static const List<String> _appBarTitles = <String>[
    'Plant Explorer & Quiz',
    'Search Plants',
    'Camera',
    'My Favourites',
    'User Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA8E6A2), // const is fine here
        title: Text(_appBarTitles[_selectedIndex]), // Title changes with tab
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.language),
            onSelected: (String value) {
              // Handle language change logic here
              print('Language selected: $value');
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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Handle refresh based on current screen
              switch (_selectedIndex) {
                case 0:
                  // Refresh Dashboard Content
                  break;
                case 1:
                  // Refresh Search Screen
                  break;
                case 2:
                  // Refresh Camera Screen
                  break;
                case 3:
                  // Refresh Favourites Screen
                  break;
                case 4:
                  // Refresh Profile Screen
                  break;
              }
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
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
