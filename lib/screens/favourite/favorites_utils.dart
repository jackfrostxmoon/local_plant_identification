import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Utility function to get the current authenticated user's ID.
String? getCurrentUserId() {
  // Returns the UID of the current user, or null if no user is logged in.
  return FirebaseAuth.instance.currentUser?.uid;
}

// Asynchronously adds a plant ID to the current user's favorite list in Firestore.
Future<void> addFavoritePlant(String plantId) async {
  // Get the current user's ID.
  final userId = getCurrentUserId();
  // If no user is logged in, return.
  if (userId == null) return;
  // Get a reference to the user's document in the 'users' collection.
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
  print('Attempting to add favorite: $plantId for user $userId');
  try {
    // Update the user's document by adding the plantId to the 'favoritePlantIds' array.
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayUnion([plantId]),
    });
    print('Successfully added favorite.');
  } catch (e) {
    // Print an error message and rethrow the exception for handling in the calling code.
    print("Error adding favorite: $e");
    // Consider showing a snackbar to the user
    throw Exception("Error adding favorite: $e"); // Rethrow for handling
  }
}

// Asynchronously removes a plant ID from the current user's favorite list in Firestore.
Future<void> removeFavoritePlant(String plantId) async {
  // Get the current user's ID.
  final userId = getCurrentUserId();
  // If no user is logged in, return.
  if (userId == null) return;
  // Get a reference to the user's document in the 'users' collection.
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
  print('Attempting to remove favorite: $plantId for user $userId');
  try {
    // Update the user's document by removing the plantId from the 'favoritePlantIds' array.
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayRemove([plantId]),
    });
    print('Successfully removed favorite.');
  } catch (e) {
    // Print an error message and rethrow the exception for handling in the calling code.
    print("Error removing favorite: $e");
    // Consider showing a snackbar to the user
    throw Exception("Error removing favorite: $e"); // Rethrow for handling
  }
}
