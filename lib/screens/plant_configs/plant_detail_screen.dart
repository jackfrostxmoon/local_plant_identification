import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  // Expecting the full data map for the selected plant
  final Map<String, dynamic> plantData;

  const PlantDetailScreen({required this.plantData, super.key});

  // Helper to build a row for displaying an attribute
  Widget _buildAttributeRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'N/A', // Handle null values gracefully
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 16), // Add a separator
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract data using the keys from your Appwrite attributes
    final String name = plantData['Name'] ?? 'Unknown Plant';
    final String? description = plantData['Description'];
    final String? growthHabit = plantData['Growth_Habit'];
    final String? interestingFact = plantData['Interesting_fact'];
    final String? toxicity = plantData['Toxicity_Humans_and_Pets'];
    final String? imageUrl =
        plantData['image']; // Assuming 'image' holds the URL

    return Scaffold(
      appBar: AppBar(
        title: Text(name), // Use plant name as title
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        // Use ListView for scrollable content
        children: [
          // Display Image prominently at the top
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrl,
                  height: 250, // Adjust height as needed
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey[600],
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image unavailable',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            // Placeholder if no image
            Container(
              height: 200,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 60,
                  color: Colors.grey[500],
                ),
              ),
            ),

          // Display Attributes using the helper
          _buildAttributeRow(context, 'Name', name),
          _buildAttributeRow(context, 'Description', description),
          _buildAttributeRow(context, 'Growth Habit', growthHabit),
          _buildAttributeRow(context, 'Interesting Fact', interestingFact),
          _buildAttributeRow(context, 'Toxicity (Humans & Pets)', toxicity),

          // Add more attributes if needed
          const SizedBox(height: 20), // Add some padding at the bottom
        ],
      ),
    );
  }
}
