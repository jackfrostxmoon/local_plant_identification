// services/appwrite_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/models.dart'; // Alias to avoid name conflicts

// --- Appwrite Configuration ---
class AppwriteConfig {
  static const String projectId = '67f50b9d003441bfb6ac';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String databaseId = '67fc674000150e152998';
  static const String flowersCollectionId = '67feed7f0034c6a85040';
  static const String herbsCollectionId = '67feefaf000e7e958cc3';
  static const String treesCollectionId = '67fef1a10005c250aa24';
  static const String plantImagesStorageId = '67fc68bc003416307fcf';
  static const String flowersquizCollectionId = '68039868002e38039bb3';
  static const String herbsquizCollectionId = '6803b4d30025e1644b19';
  static const String treesquizCollectionId = '6803b92b0003cbbca918';
}

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  late final Client client;
  late final Databases databases;
  late final Storage storage;

  factory AppwriteService() {
    return _instance;
  }

  AppwriteService._internal() {
    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);

    databases = Databases(client);
    storage = Storage(client);
  }

  // --- Generic method to fetch documents from any collection ---
  Future<List<Map<String, dynamic>>> _fetchCollectionData(
    String collectionId,
    String itemType,
  ) async {
    try {
      final models.DocumentList response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: collectionId,
      );

      // Map Appwrite documents and add the item type
      return response.documents.map((doc) {
        // Create a mutable copy and add the type
        final data = Map<String, dynamic>.from(doc.data);
        data['item_type'] = itemType; // Add a type identifier
        return data;
      }).toList();
    } on AppwriteException catch (e) {
      print(
        'Appwrite Error fetching $itemType documents from $collectionId: ${e.message}',
      );
      throw Exception('Failed to fetch $itemType documents: ${e.message}');
    } catch (e) {
      print('Error fetching $itemType documents from $collectionId: $e');
      throw Exception(
        'An unexpected error occurred while fetching $itemType documents.',
      );
    }
  }

  // --- Specific methods using the generic fetcher ---
  Future<List<Map<String, dynamic>>> fetchAllFlowers() async {
    return _fetchCollectionData(AppwriteConfig.flowersCollectionId, 'Flower');
  }

  Future<List<Map<String, dynamic>>> fetchAllHerbs() async {
    return _fetchCollectionData(AppwriteConfig.herbsCollectionId, 'Herb');
  }

  Future<List<Map<String, dynamic>>> fetchAllTrees() async {
    return _fetchCollectionData(AppwriteConfig.treesCollectionId, 'Tree');
  }

  // --- Combined method to fetch all plant types ---
  Future<List<Map<String, dynamic>>> fetchAllPlants() async {
    try {
      // Fetch all types concurrently
      final results = await Future.wait([
        fetchAllFlowers(),
        fetchAllHerbs(),
        fetchAllTrees(),
      ]);

      // Combine the results from all fetches into a single list
      final combinedList = results.expand((list) => list).toList();

      // Optional: Shuffle the list for variety if desired
      // combinedList.shuffle();

      return combinedList;
    } catch (e) {
      print("Error fetching all plant data: $e");
      // Rethrow the error so the FutureBuilder can catch it
      throw Exception("Failed to load plant data: $e");
    }
  }
}

class Question {
  final String id; // Appwrite document ID
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? imageUrl; // Nullable image URL

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl,
  });

  factory Question.fromAppwriteDoc(Document doc) {
    // Ensure options are parsed correctly as List<String>
    List<String> parsedOptions = [];
    if (doc.data['Options'] is List) {
      // Appwrite SDK might return List<dynamic>, so cast safely
      parsedOptions = List<String>.from(
        doc.data['Options'].map((item) => item.toString()),
      );
    }

    // Handle potential null or empty image URL
    String? imageUrl = doc.data['Image'];
    if (imageUrl != null && imageUrl.trim().isEmpty) {
      imageUrl = null;
    }

    return Question(
      id: doc.$id,
      questionText: doc.data['Questions'] ?? 'Error: Missing question text',
      options: parsedOptions,
      correctAnswerIndex:
          doc.data['Correct_Answer_Index'] ?? 0, // Default to 0 if missing
      imageUrl: imageUrl,
    );
  }
}
