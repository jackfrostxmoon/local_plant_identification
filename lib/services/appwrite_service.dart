import 'package:appwrite/appwrite.dart';

// Appwrite Configuration
class AppwriteConfig {
  static const String projectId = '67f50b9d003441bfb6ac';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String databaseId = 'your-database-id';
}

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  late final Client client;
  late final Account account;
  late final Databases databases;

  factory AppwriteService() {
    return _instance;
  }

  AppwriteService._internal() {
    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId)
        .setSelfSigned(status: true); // For self-signed certificates
    account = Account(client);
    databases = Databases(client);
  }

  // Authentication methods
  Future<void> createAccount(String email, String password, String name) async {
    try {
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      rethrow;
    }
  }

  /*Future<void> login(String email, String password) async {
    try {
      await account.createEmailSession(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }
  */
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await account.createRecovery(
        email: email,
        url:
            'https://lpi-app.com/reset-password', // Replace with your actual reset password URL
      );
    } catch (e) {
      rethrow;
    }
  }

  // Database methods
  Future<Map<String, dynamic>> createDocument(
    String collectionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDocument(
    String collectionId,
    String documentId,
  ) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
