// services/appwrite_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

// --- Appwrite Configuration ---
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

  // This is the ID for the storage bucket where images are stored
  static const String plantImagesStorageId = '67fc68bc003416307fcf';

  // Quiz collection IDs
  static const String flowersquizCollectionId = '68039868002e38039bb3';
  static const String herbsquizCollectionId = '6803b4d30025e1644b19';
  static const String treesquizCollectionId = '6803b92b0003cbbca918';

  // --- Attributes to search across ---
  // IMPORTANT: Ensure Full-Text Indexes exist for ALL these in Appwrite!
  // MODIFIED: Added localized attributes based on the provided index image
  static const List<String> searchableAttributes = [
    // Base English Attributes (Indexes 1-5)
    'Name',
    'Description',
    'Growth_Habit',
    'Interesting_fact',
    'Toxicity_Humans_and_Pets',
    // Malay Attributes (Indexes 6, 8, 10, 12, 14)
    'Name_MS',
    'Description_MS',
    'Growth_Habit_MS',
    'Interesting_fact_MS',
    'Toxicity_Humans_and_Pets_MS',
    // Chinese Attributes (Indexes 7, 9, 11, 13, 15)
    'Name_ZH', // Assuming Name_ZH corresponds to index_7
    'Description_ZH',
    'Growth_Habit_ZH',
    'Interesting_fact_ZH',
    'Toxicity_Humans_and_Pets_ZH',
  ];
}

// --- AppwriteService Class (No changes needed in the methods below) ---
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
        .setProject(AppwriteConfig.projectId)
        .setSelfSigned(status: true); // Use true only for development

    databases = Databases(client);
    storage = Storage(client);
  }

  // --- _fetchCollectionData (No changes needed) ---
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
      return [];
    } catch (e) {
      print('Error fetching/searching $itemType from $collectionId: $e');
      return [];
    }
  }

  // --- Specific fetch methods (No changes needed) ---
  Future<List<Map<String, dynamic>>> fetchAllFlowers() async {
    return _fetchCollectionData(AppwriteConfig.flowersCollectionId, 'Flower');
  }

  Future<List<Map<String, dynamic>>> fetchAllHerbs() async {
    return _fetchCollectionData(AppwriteConfig.herbsCollectionId, 'Herb');
  }

  Future<List<Map<String, dynamic>>> fetchAllTrees() async {
    return _fetchCollectionData(AppwriteConfig.treesCollectionId, 'Tree');
  }

  // --- Combined fetch all (No changes needed) ---
  Future<List<Map<String, dynamic>>> fetchAllPlants() async {
    try {
      final results = await Future.wait([
        fetchAllFlowers(),
        fetchAllHerbs(),
        fetchAllTrees(),
      ]);
      final combinedList = results.expand((list) => list).toList();
      return combinedList;
    } catch (e) {
      print("Error fetching all plant data: $e");
      throw Exception("Failed to load plant data: $e");
    }
  }

  // --- searchPlants (No changes needed in this method itself) ---
  // This method already iterates through the AppwriteConfig.searchableAttributes list.
  // By adding the localized keys to that list, this method will automatically include them.
  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      // Return all plants if query is empty (matching previous behavior)
      return fetchAllPlants();
      // Or return empty list: return [];
    }

    final collectionsToSearch = [
      {'id': AppwriteConfig.flowersCollectionId, 'type': 'Flower'},
      {'id': AppwriteConfig.herbsCollectionId, 'type': 'Herb'},
      {'id': AppwriteConfig.treesCollectionId, 'type': 'Tree'},
    ];

    final List<Future<List<Map<String, dynamic>>>> searchFutures = [];

    for (var collectionInfo in collectionsToSearch) {
      // Loop through ALL attributes defined in the config list
      for (var attribute in AppwriteConfig.searchableAttributes) {
        final List<String> searchQueries = [
          Query.search(attribute, trimmedQuery),
        ];
        searchFutures.add(
          _fetchCollectionData(
            collectionInfo['id']!,
            collectionInfo['type']!,
            queries: searchQueries,
          ),
        );
      }
    }

    try {
      final List<List<Map<String, dynamic>>> resultsByAttribute =
          await Future.wait(searchFutures);

      final Map<String, Map<String, dynamic>> uniqueResults = {};
      for (var resultList in resultsByAttribute) {
        for (var plantData in resultList) {
          final String? docId = plantData['\$id'];
          if (docId != null && !uniqueResults.containsKey(docId)) {
            uniqueResults[docId] = plantData;
          }
        }
      }

      final combinedList = uniqueResults.values.toList();
      print(
        "Search for '$trimmedQuery' found ${combinedList.length} unique plants.",
      );
      return combinedList;
    } catch (e) {
      print("Error during combined plant search for '$trimmedQuery': $e");
      return [];
    }
  }

  // --- Get Plant Details by ID (No changes needed) ---
  Future<Map<String, dynamic>?> getPlantDetailsById(String plantId) async {
    final collectionsToSearch = [
      {'id': AppwriteConfig.flowersCollectionId, 'type': 'Flower'},
      {'id': AppwriteConfig.herbsCollectionId, 'type': 'Herb'},
      {'id': AppwriteConfig.treesCollectionId, 'type': 'Tree'},
    ];

    for (var collectionInfo in collectionsToSearch) {
      try {
        final models.Document document = await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: collectionInfo['id']!,
          documentId: plantId,
        );
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
        // If 404, continue to the next collection
      } catch (e) {
        print(
          'Generic Error fetching $plantId from ${collectionInfo['id']}: $e',
        );
        throw Exception(
          'An unexpected error occurred fetching plant details for $plantId.',
        );
      }
    }
    print("Plant with ID $plantId not found in any specified collection.");
    return null;
  }
}
