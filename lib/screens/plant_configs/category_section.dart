import 'package:flutter/material.dart';
// Adjust package name as needed.
import 'package:local_plant_identification/screens/plant_configs/plant_item_card.dart';

/// Displays a category title followed by a horizontal list of PlantItemCards for that category.
class CategorySection extends StatelessWidget {
  final String title; // The title of the category (e.g., "Flowers").
  final List<Map<String, dynamic>>
      plants; // The list of plant data maps for this category.

  // Constructor for the CategorySection widget.
  const CategorySection({required this.title, required this.plants, super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the content in a Card to provide elevation and a consistent background.
    return Card(
      // The container inside the Card holds the actual content and applies decoration.
      child: Container(
        padding: const EdgeInsets.all(12.0), // Padding around the content.
        decoration: BoxDecoration(
          color: const Color(
              0xFFA8E6A2), // Light green background color for the section.
          borderRadius: BorderRadius.circular(
              16.0), // Rounded corners matching the Card's shape.
          border: Border.all(
              color: Colors.black,
              width: 4.0), // Black border around the section.
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align children to the start (left).
          children: [
            // Display the Category Title.
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 12.0, left: 4.0), // Padding for the title.
              child: Text(
                title, // The category title.
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, // Make the title bold.
                    ),
              ),
            ),
            // Horizontal List View for displaying plant cards.
            SizedBox(
              height: 180, // Fixed height for the horizontal list.
              child: plants.isEmpty
                  ? Center(
                      // Display a message if there are no plants in this category.
                      child: Text(
                        // Provide a generic message including the category title.
                        'No ${title.toLowerCase()} found.',
                        style: TextStyle(
                            color: Colors.grey[600]), // Grey text color.
                      ),
                    )
                  : ListView.builder(
                      scrollDirection:
                          Axis.horizontal, // Make the list scroll horizontally.
                      itemCount:
                          plants.length, // The number of items in the list.
                      itemBuilder: (context, index) {
                        // Build a PlantItemCard for each plant in the list.
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
