// models/plant.dart
class Plant {
  final String id;
  final String name;
  final String type; // "Flowers" or "Herbs"
  final String imageUrl;
  final String description;
  final String nurturingSteps;
  final String interestingFact;
  final String mostlyFoundAreas;
  final String hazardInfo;
  bool isFavorite;

  Plant({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.description,
    required this.nurturingSteps,
    required this.interestingFact,
    required this.mostlyFoundAreas,
    required this.hazardInfo,
    this.isFavorite = false,
  });
}