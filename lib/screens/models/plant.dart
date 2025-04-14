class Plant {
  final String id;
  final String name;
  final String description;
  final String careInstructions;
  final String wateringFrequency;
  final String sunlightNeeds;

  Plant({
    required this.id,
    required this.name,
    required this.description,
    required this.careInstructions,
    required this.wateringFrequency,
    required this.sunlightNeeds,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['\$id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      careInstructions: json['careInstructions'] ?? '',
      wateringFrequency: json['wateringFrequency'] ?? '',
      sunlightNeeds: json['sunlightNeeds'] ?? '',
    );
  }
}
