import 'package:appwrite/appwrite.dart';
import 'package:local_plant_identification/screens/models/plant.dart';
import 'package:local_plant_identification/services/appwrite_config.dart';

class PlantService {
  static final PlantService _instance = PlantService._internal();
  factory PlantService() => _instance;

  final Client client;
  final Databases databases;

  PlantService._internal()
    : client = Client()
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId),
      databases = Databases(
        Client()
            .setEndpoint(AppwriteConfig.endpoint)
            .setProject(AppwriteConfig.projectId),
      );

  Future<List<Plant>> getPlants() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.categoriesCollectionId,
      );

      return response.documents.map((doc) => Plant.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to get plants: $e');
    }
  }

  Future<Plant> addPlant({
    required String name,
    required String description,
    required String careInstructions,
    required String wateringFrequency,
    required String sunlightNeeds,
  }) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.categoriesCollectionId,
        documentId: ID.unique(),
        data: {
          'name': name,
          'description': description,
          'careInstructions': careInstructions,
          'wateringFrequency': wateringFrequency,
          'sunlightNeeds': sunlightNeeds,
        },
      );

      return Plant.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add plant: $e');
    }
  }

  Future<void> updatePlant({
    required String documentId,
    required String name,
    required String description,
    required String careInstructions,
    required String wateringFrequency,
    required String sunlightNeeds,
  }) async {
    try {
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.categoriesCollectionId,
        documentId: documentId,
        data: {
          'name': name,
          'description': description,
          'careInstructions': careInstructions,
          'wateringFrequency': wateringFrequency,
          'sunlightNeeds': sunlightNeeds,
        },
      );
    } catch (e) {
      throw Exception('Failed to update plant: $e');
    }
  }

  Future<void> deletePlant(String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.categoriesCollectionId,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception('Failed to delete plant: $e');
    }
  }
}
