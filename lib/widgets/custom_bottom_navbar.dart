import 'package:flutter/material.dart';

// Helper class to hold item data (Icon and Label)
class NavBarItem {
  final IconData icon;
  final String label;

  const NavBarItem({required this.icon, required this.label});
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  // Required callback to notify the parent
  final ValueChanged<int> onItemTapped;
  // List of items to display
  final List<NavBarItem> items;
  // Optional index for the FAB gap
  final int? fabIndex; // e.g., 2 means gap before index 2

  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
    this.fabIndex,
    this.backgroundColor = const Color(0xFFDCEDC8),
    this.selectedItemColor = Colors.black87,
    this.unselectedItemColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure fabIndex is valid if provided
    final bool hasFabGap =
        fabIndex != null && fabIndex! >= 0 && fabIndex! <= items.length;

    return BottomAppBar(
      color: backgroundColor,
      // Consider adding notch shape if using a FAB
      // shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length + (hasFabGap ? 1 : 0), (index) {
            // Adjust index to account for the FAB gap
            int itemIndex;
            if (!hasFabGap) {
              itemIndex = index;
            } else if (index < fabIndex!) {
              itemIndex = index;
            } else if (index == fabIndex!) {
              // Insert the FAB Gap
              return const SizedBox(width: 40);
            } else {
              itemIndex = index - 1; // Decrement index after the gap
            }

            // Build the actual item
            return _buildNavItem(
              item: items[itemIndex],
              index: itemIndex,
              isSelected: selectedIndex == itemIndex,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavBarItem item,
    required int index,
    required bool isSelected,
  }) {
    final Color itemColor =
        isSelected ? selectedItemColor : unselectedItemColor;

    return InkWell(
      onTap: () => onItemTapped(index), // Just call the callback
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(item.icon, color: itemColor, size: 24),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: itemColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Example Usage in a Parent StatefulWidget ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Define items and routes/actions here
  final List<NavBarItem> _navBarItems = const [
    NavBarItem(icon: Icons.home_outlined, label: 'Home'),
    NavBarItem(icon: Icons.search, label: 'Search'),
    NavBarItem(icon: Icons.favorite_outline, label: 'Favourite'),
    NavBarItem(icon: Icons.person_outline, label: 'User'),
  ];

  final List<String> _routeNames = [
    '/homepage',
    '/dashboard',
    '/favourites',
    '/user',
  ];

  // Or use a PageController if managing pages directly
  // final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Avoid redundant navigation

    setState(() {
      _selectedIndex = index;
    });

    // --- Navigation/Action Logic is now HERE ---
    final routeName = _routeNames[index];
    print('Parent navigating to route: $routeName');
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);

    // Or if using PageView:
    // _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Example Body (could be PageView or Navigator)
      body: Center(child: Text('Selected Screen Index: $_selectedIndex')),

      // Example FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        // backgroundColor: Colors.amber, // Example color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: CustomBottomNavBar(
        items: _navBarItems,
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        fabIndex: 2, // Place gap before the 3rd item (index 2)
        // Optional styling overrides
        // backgroundColor: Colors.lightGreen.shade100,
        // selectedItemColor: Colors.deepPurple,
      ),
    );
  }
}
