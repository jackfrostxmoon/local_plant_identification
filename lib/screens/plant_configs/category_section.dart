import 'package:flutter/material.dart';
// Adjust package name as needed
import 'package:local_plant_identification/screens/plant_configs/plant_item_card.dart';

/// Displays a category title and a horizontal list of PlantItemCards.
class CategorySection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> plants;

  const CategorySection({required this.title, required this.plants, super.key});

  @override
  Widget build(BuildContext context) {
    // Use Card defined by the theme for the outer container
    return Card(
      child: Container(
        // Apply decoration directly to the container inside the Card
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFA8E6A2), // Light green background
          borderRadius: BorderRadius.circular(16.0), // Match Card's shape
          border: Border.all(color: Colors.black, width: 4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Title
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Horizontal List View
            SizedBox(
              height: 180,
              child:
                  plants.isEmpty
                      ? Center(
                        child: Text(
                          'No ${title.toLowerCase()} found.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: plants.length,
                        itemBuilder: (context, index) {
                          // Use the PlantItemCard widget here
                          return PlantItemCard(plant: plants[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
