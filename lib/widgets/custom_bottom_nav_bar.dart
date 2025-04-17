import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; // Callback for main items
  final VoidCallback onFabTap; // Callback for FAB

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors (adjust as needed)
    const Color primaryGreen = Color(0xFF5DB075); // Darker green for FAB
    const Color backgroundGreen = Color(0xFFD5E8D4); // Lighter green for bar
    const Color selectedColor = primaryGreen; // Color for selected item
    const Color unselectedColor = Colors.black54; // Color for unselected items

    return BottomAppBar(
      color: backgroundGreen,
      shape: const CircularNotchedRectangle(), // Creates the notch
      notchMargin: 8.0, // Space between FAB and AppBar
      child: Padding(
        // Add padding to prevent items hitting screen edges
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          // Icons and labels
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(
              icon: Icons.home_outlined, // Or Icons.home for filled
              label: 'Home',
              index: 0,
              isSelected: currentIndex == 0,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                Navigator.pushNamed(context, '/home');
                onTap(0);
              },
            ),
            _buildNavItem(
              icon: Icons.search,
              label: 'Search',
              index: 1,
              isSelected: currentIndex == 1,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                Navigator.pushNamed(context, '/search');
                onTap(1);
              },
            ),
            const SizedBox(width: 40), // Placeholder for the FAB notch area
            _buildNavItem(
              icon: Icons.favorite_border, // Or Icons.favorite for filled
              label: 'Favourite',
              index: 2,
              isSelected: currentIndex == 2,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                Navigator.pushNamed(context, '/favourite');
                onTap(2);
              },
            ),
            _buildNavItem(
              icon: Icons.person_outline, // Or Icons.person for filled
              label: 'User',
              index: 3,
              isSelected: currentIndex == 3,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                Navigator.pushNamed(context, '/profile');
                onTap(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each navigation item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final Color color = isSelected ? selectedColor : unselectedColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Optional: for splash effect
      child: Padding(
        // Add padding around each item for better touch area
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum vertical space
          children: <Widget>[
            Icon(icon, color: color, size: 24.0),
            const SizedBox(height: 4.0), // Space between icon and label
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.0,
                // fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Floating Action Button (Place this in your Scaffold) ---

Widget buildFab(BuildContext context, VoidCallback onPressed) {
  const Color primaryGreen = Color(0xFF5DB075); // Darker green for FAB

  return FloatingActionButton(
    onPressed: onPressed,
    backgroundColor: primaryGreen,
    foregroundColor: Colors.black87, // Icon color
    // Make it slightly squarish with rounded corners like the image
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // Adjust radius as needed
    ),
    elevation: 2.0, // Slight shadow
    child: const Icon(Icons.camera_alt_outlined, size: 28.0), // Camera icon
  );
}
