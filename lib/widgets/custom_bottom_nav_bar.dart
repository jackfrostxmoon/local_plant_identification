import 'package:flutter/material.dart';

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
    // Using the icons from your latest snippet
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home), // Changed from home
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Camera',
        ), // Changed from camera
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourite'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
