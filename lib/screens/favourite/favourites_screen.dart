import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/favourite/favourite_list_item.dart';
import 'package:local_plant_identification/screens/plant_configs/empty_data_message.dart';
import 'package:local_plant_identification/screens/plant_configs/loading_indicator.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';

// Adjust import paths as needed
class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  bool _isLoading = false;
  // Placeholder list - replace with actual data fetching/state management
  List<Map<String, dynamic>> _favouriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  // Simulate loading favourites
  Future<void> _loadFavourites() async {
    setState(() => _isLoading = true);
    // TODO: Replace with actual data fetching (e.g., from local storage, database)
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate network delay

    // Example placeholder data
    setState(() {
      _favouriteItems = [
        {
          'id': 'plant_1',
          'Name': 'Daisy', // Use 'Name' to match PlantDetailScreen expectation
          'imageUrl': '', // Leave empty to show placeholder icon
          'isFavourite': true,
          // Add other attributes needed by PlantDetailScreen
          'Description': 'A common flower.',
          'Growth_Habit': 'Herbaceous',
          'Interesting_fact': 'Daisies close their petals at night.',
          'Toxicity_Humans_and_Pets': 'Generally non-toxic',
          'image': '', // Match key used in PlantDetailScreen
        },
        {
          'id': 'plant_2',
          'Name': 'Oak Tree',
          'imageUrl':
              'https://via.placeholder.com/60', // Example placeholder URL
          'isFavourite': true,
          'Description': 'A large deciduous tree.',
          'Growth_Habit': 'Tree',
          'Interesting_fact': 'Acorns come from oak trees.',
          'Toxicity_Humans_and_Pets': 'Acorns can be toxic to pets.',
          'image':
              'https://via.placeholder.com/250', // Example detail image URL
        },
        {
          'id': 'plant_3',
          'Name': 'Basil',
          'imageUrl': '',
          'isFavourite': true,
          'Description': 'A culinary herb.',
          'Growth_Habit': 'Herb',
          'Interesting_fact': 'Used in pesto.',
          'Toxicity_Humans_and_Pets': 'Non-toxic',
          'image': '',
        },
        // Add more items...
      ];
      _isLoading = false;
    });
  }

  // Handle toggling favourite status
  void _toggleFavourite(String itemId) {
    setState(() {
      // Find the item index
      final index = _favouriteItems.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        // In a real app, you'd likely remove it from the favourites list/storage
        // For this example, we'll just toggle the flag (which might hide it
        // if the list is strictly filtered for isFavourite == true elsewhere)
        // OR simply remove it:
        _favouriteItems.removeAt(index);

        // Example of toggling flag instead of removing:
        // _favouriteItems[index]['isFavourite'] = !_favouriteItems[index]['isFavourite'];

        // TODO: Update persistent storage (local DB, API, etc.)
        print('Toggled favourite for $itemId');
      }
    });
  }

  // Handle view button press
  void _viewItem(Map<String, dynamic> itemData) {
    // Navigate to the detail screen, passing the item data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantDetailScreen(plantData: itemData),
      ),
    );
    print('Viewing item: ${itemData['Name']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        // Optional: Add actions like clear all
      ),
      body:
          _isLoading
              ? const LoadingIndicator()
              : _favouriteItems.isEmpty
              ? const EmptyDataMessage(
                message: 'You have no favourite items yet.',
              )
              : ListView.builder(
                itemCount: _favouriteItems.length,
                itemBuilder: (context, index) {
                  final item = _favouriteItems[index];
                  return FavouriteListItem(
                    // Use empty string for imageUrl if null or missing
                    imageUrl: item['imageUrl'] ?? '',
                    title: item['Name'] ?? '---', // Use Name field
                    isFavourite: item['isFavourite'] ?? false,
                    onViewPressed: () => _viewItem(item),
                    onFavouritePressed: () => _toggleFavourite(item['id']),
                  );
                },
              ),
    );
  }
}
