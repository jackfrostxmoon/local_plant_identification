// screens/favorite_page.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/favourite/plant.dart';

class FavoritePage extends StatelessWidget {
  final List<Plant> favoritePlants;
  final Function(Plant) onViewPlant;
  final Function(Plant) onToggleFavorite;

  const FavoritePage({
    Key? key,
    required this.favoritePlants,
    required this.onViewPlant,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favourite'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Sign out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body:
          favoritePlants.isEmpty
              ? const Center(child: Text('No favorite plants yet'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoritePlants.length,
                itemBuilder: (context, index) {
                  final plant = favoritePlants[index];
                  return _buildFavoriteItem(plant);
                },
              ),
    );
  }

  Widget _buildFavoriteItem(Plant plant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.lightGreen[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Plant image
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                plant.imageUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        plant.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, color: Colors.grey);
                        },
                      ),
                    )
                    : const Icon(Icons.image, color: Colors.grey),
          ),

          // Plant name and dashed line
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  color: Colors.grey[300],
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 5,
                        height: 1,
                        color: Colors.transparent,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Favorite icon
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => onToggleFavorite(plant),
          ),

          // View button
          TextButton(
            onPressed: () => onViewPlant(plant),
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
