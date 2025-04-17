import 'package:flutter/material.dart';
// Import the custom nav bar widget file
import 'package:local_plant_identification/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Start with the 'Home' tab selected

  // Placeholder pages for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home Page')),
    Center(child: Text('Search Page')),
    Center(child: Text('Favourite Page')),
    Center(child: Text('User Page')),
    // You might have a dedicated page/modal for the camera action
    Center(child: Text('Camera Action Triggered')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation or state change for main items
    print("Tapped item index: $index");
  }

  void _onFabTapped() {
    // Handle the action for the central Floating Action Button
    // This could open the camera, show a modal, navigate, etc.
    print("FAB Tapped!");
    // Example: Show a temporary message or navigate
    // setState(() {
    //   _selectedIndex = 4; // Or handle differently
    // });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera action!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false, // Add this line to prevent the notch effect
      // Optional AppBar
      appBar: AppBar(
        title: const Text('My App'),
        backgroundColor: const Color(0xFFD5E8D4), // Match bar background
        elevation: 0,
      ),

      // Body content changes based on selected index
      body: IndexedStack(
        // Use IndexedStack to keep page state
        index: _selectedIndex,
        children: _widgetOptions.sublist(0, 4), // Only show main pages here
      ),
      // body: _widgetOptions.elementAt(_selectedIndex), // Simpler alternative

      // --- Integration ---
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        onFabTap: _onFabTapped, // Pass the FAB tap handler
      ),
      floatingActionButton: buildFab(
        context,
        _onFabTapped,
      ), // Use the FAB builder
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // --- End Integration ---
    );
  }
}
