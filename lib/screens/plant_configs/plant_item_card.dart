import 'package:flutter/material.dart';

/// Displays a single plant item with image, divider, and name.
class PlantItemCard extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantItemCard({required this.plant, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Area
          Expanded(
            child: Container(
              color: Colors.white,
              child:
                  (plant['image'] != null &&
                          plant['image'].toString().isNotEmpty)
                      ? Image.network(
                        plant['image'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.black,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: Colors.black,
                            ),
                          );
                        },
                      )
                      : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
            ),
          ),
          // Separator Line
          const Divider(height: 1, thickness: 1, color: Colors.black),
          // Name Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: const Color(0xFFCEE8D3), // Light green background
            child: Text(
              plant['Name'] ?? 'N/A',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
