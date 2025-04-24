// utils/favorites_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String? getCurrentUserId() {
  return FirebaseAuth.instance.currentUser?.uid;
}

Future<void> addFavoritePlant(String plantId) async {
  final userId = getCurrentUserId();
  if (userId == null) return;
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
  print('Attempting to add favorite: $plantId for user $userId');
  try {
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayUnion([plantId]),
    });
    print('Successfully added favorite.');
  } catch (e) {
    print("Error adding favorite: $e");
    // Consider showing a snackbar to the user
    throw Exception("Error adding favorite: $e"); // Rethrow for handling
  }
}

Future<void> removeFavoritePlant(String plantId) async {
  final userId = getCurrentUserId();
  if (userId == null) return;
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
  print('Attempting to remove favorite: $plantId for user $userId');
  try {
    await userDocRef.update({
      'favoritePlantIds': FieldValue.arrayRemove([plantId]),
    });
    print('Successfully removed favorite.');
  } catch (e) {
    print("Error removing favorite: $e");
    // Consider showing a snackbar to the user
    throw Exception("Error removing favorite: $e"); // Rethrow for handling
  }
}
