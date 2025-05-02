// services/appwrite_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

// --- Appwrite Configuration ---
// Holds essential Appwrite IDs and endpoint.
class AppwriteConfig {
  // Replace with your actual Appwrite project ID and endpoint
  static const String projectId = '67f50b9d003441bfb6ac';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String databaseId = '67fc674000150e152998';

  // Collection IDs for different plant types
  static const String flowersCollectionId = '67feed7f0034c6a85040';
  static const String herbsCollectionId = '67feefaf000e7e958cc3';
  static const String treesCollectionId =
      '67fef1a10005c250aa24'; // Corrected based on image

  // Storage bucket ID for plant images
  static const String plantImagesStorageId = '67fc68bc003416307fcf';

  // Collection IDs specifically for quiz questions
  static const String flowersquizCollectionId = '68039868002e38039bb3';
  static const String herbsquizCollectionId = '6803b4d30025e1644b19';
  static const String treesquizCollectionId = '6803b92b0003cbbca918';

  // --- Attributes for Search ---
  // IMPORTANT: Full-Text Indexes must exist for ALL these in Appwrite!
  static const List<String> searchableAttributes = [
    // English, Malay, and Chinese attributes used for searching
    'Name', 'Description', 'Growth_Habit', 'Interesting_fact',
    'Toxicity_Humans_and_Pets',
    'Name_MS', 'Description_MS', 'Growth_Habit_MS', 'Interesting_fact_MS',
    'Toxicity_Humans_and_Pets_MS',
    'Name_ZH', 'Description_ZH', 'Growth_Habit_ZH', 'Interesting_fact_ZH',
    'Toxicity_Humans_and_Pets_ZH',
  ];
}

// --- AppwriteService Class ---
// Singleton for Appwrite backend interactions.
class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  late final Client client;
  late final Databases databases;
  late final Storage storage;

  factory AppwriteService() {
    return _instance;
  }

  // Initialize Appwrite client and services. Use setSelfSigned(true) ONLY for development.
  AppwriteService._internal() {
    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId)
        .setSelfSigned(status: true); // Remove or set false for production

    databases = Databases(client);
    storage = Storage(client);
  }

  // --- _fetchCollectionData Helper ---
  // Generic method to fetch documents from a collection.
  Future<List<Map<String, dynamic>>> _fetchCollectionData(
    String collectionId,
    String itemType, {
    List<String>? queries,
  }) async {
    try {
      final models.DocumentList response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: collectionId,
        queries: queries,
      );
      // Map documents, add item_type and \$id.
      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['item_type'] = itemType;
        data['\$id'] = doc.$id;
        return data;
      }).toList();
    } on AppwriteException catch (e) {
      print(
        'Appwrite Error fetching/searching $itemType from $collectionId: ${e.message}',
      );
      return []; // Return empty on error
    } catch (e) {
      print('Error fetching/searching $itemType from $collectionId: $e');
      return []; // Return empty on error
    }
  }

  // --- Specific Fetch Methods ---
  Future<List<Map<String, dynamic>>> fetchAllFlowers() async {
    return _fetchCollectionData(AppwriteConfig.flowersCollectionId, 'Flower');
  }

  Future<List<Map<String, dynamic>>> fetchAllHerbs() async {
    return _fetchCollectionData(AppwriteConfig.herbsCollectionId, 'Herb');
  }

  Future<List<Map<String, dynamic>>> fetchAllTrees() async {
    return _fetchCollectionData(AppwriteConfig.treesCollectionId, 'Tree');
  }

  // --- Combined Fetch All Plants ---
  // Fetches all plants from all specified collections concurrently.
  Future<List<Map<String, dynamic>>> fetchAllPlants() async {
    try {
      final results = await Future.wait([
        fetchAllFlowers(),
        fetchAllHerbs(),
        fetchAllTrees(),
      ]);
      // Combine results into a single list.
      return results.expand((list) => list).toList();
    } catch (e) {
      print("Error fetching all plant data: $e");
      throw Exception("Failed to load plant data: $e");
    }
  }

  // --- searchPlants ---
  // Searches across collections and searchable attributes.
  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return fetchAllPlants(); // Return all if query is empty.
    }

    final collectionsToSearch = [
      {'id': AppwriteConfig.flowersCollectionId, 'type': 'Flower'},
      {'id': AppwriteConfig.herbsCollectionId, 'type': 'Herb'},
      {'id': AppwriteConfig.treesCollectionId, 'type': 'Tree'},
    ];

    final List<Future<List<Map<String, dynamic>>>> searchFutures = [];

    // Search each collection for each searchable attribute.
    for (var collectionInfo in collectionsToSearch) {
      for (var attribute in AppwriteConfig.searchableAttributes) {
        searchFutures.add(
          _fetchCollectionData(
            collectionInfo['id']!,
            collectionInfo['type']!,
            queries: [Query.search(attribute, trimmedQuery)],
          ),
        );
      }
    }

    try {
      // Wait for all search futures to complete.
      final List<List<Map<String, dynamic>>> resultsByAttribute =
          await Future.wait(searchFutures);

      // Combine and filter for unique plants by document ID.
      final Map<String, Map<String, dynamic>> uniqueResults = {};
      for (var resultList in resultsByAttribute) {
        for (var plantData in resultList) {
          final String? docId = plantData['\$id'];
          if (docId != null && !uniqueResults.containsKey(docId)) {
            uniqueResults[docId] = plantData;
          }
        }
      }

      // Convert the map of unique results back to a list.
      final combinedList = uniqueResults.values.toList();
      print(
        "Search for '$trimmedQuery' found ${combinedList.length} unique plants.",
      );
      return combinedList;
    } catch (e) {
      print("Error during combined plant search for '$trimmedQuery': $e");
      return []; // Return empty on error
    }
  }

  // --- Get Plant Details by ID ---
  // Fetches a single plant document by ID across collections.
  Future<Map<String, dynamic>?> getPlantDetailsById(String plantId) async {
    final collectionsToSearch = [
      {'id': AppwriteConfig.flowersCollectionId, 'type': 'Flower'},
      {'id': AppwriteConfig.herbsCollectionId, 'type': 'Herb'},
      {'id': AppwriteConfig.treesCollectionId, 'type': 'Tree'},
    ];

    // Iterate collections to find the plant by ID.
    for (var collectionInfo in collectionsToSearch) {
      try {
        final models.Document document = await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: collectionInfo['id']!,
          documentId: plantId,
        );
        // If found, map data and return.
        final data = Map<String, dynamic>.from(document.data);
        data['\$id'] = document.$id;
        data['item_type'] = collectionInfo['type'];
        return data;
      } on AppwriteException catch (e) {
        if (e.code != 404) {
          print(
            'Appwrite Error fetching $plantId from ${collectionInfo['id']}: ${e.message}',
          );
          throw Exception(
            'Failed to fetch plant details for $plantId: ${e.message}',
          );
        }
        // Continue if 404 (not found in this collection).
      } catch (e) {
        print(
          'Generic Error fetching $plantId from ${collectionInfo['id']}: $e',
        );
        throw Exception(
          'An unexpected error occurred fetching plant details for $plantId.',
        );
      }
    }
    // If not found in any collection, log and return null.
    print("Plant with ID $plantId not found in any specified collection.");
    return null; // Return null if not found in any collection.
  }
}
