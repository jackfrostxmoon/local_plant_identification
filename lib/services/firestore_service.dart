// lib/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service class for interacting with user profile data in Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'users';

  /// Retrieves a real-time stream of the user's document snapshot.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _db.collection(_collectionPath).doc(uid).snapshots();
  }

  /// Fetches the user's document data once. Throws FirebaseException on failure.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    try {
      return await _db.collection(_collectionPath).doc(uid).get();
    } on FirebaseException catch (e) {
      debugPrint("Error fetching user data for $uid: $e");
      rethrow;
    }
  }

  /// Updates the username for a specific user. Throws FirebaseException on failure.
  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      await _db.collection(_collectionPath).doc(uid).update({
        'username': newUsername,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("Username updated successfully for $uid.");
    } on FirebaseException catch (e) {
      debugPrint("Error updating username for $uid: $e");
      rethrow;
    }
  }

  /// Updates a specific field in the user's profile document. Throws FirebaseException on failure.
  Future<void> updateUserProfileField(
    String uid,
    String field,
    dynamic value,
  ) async {
    try {
      await _db.collection(_collectionPath).doc(uid).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("Field '$field' updated successfully for $uid.");
    } on FirebaseException catch (e) {
      debugPrint("Error updating field '$field' for $uid: $e");
      rethrow;
    }
  }

  /// Creates a basic user profile document if it doesn't exist. Returns true if created, false if existed.
  Future<bool> createBasicUserProfileIfNeeded(
    User user,
    String identifier,
  ) async {
    final docRef = _db.collection(_collectionPath).doc(user.uid);

    try {
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        String initialUsername;
        String? initialEmail;

        if (identifier.contains('@') && identifier.length > 1) {
          initialEmail = identifier;
          initialUsername = identifier.split('@')[0];
        } else {
          initialEmail = null;
          initialUsername = identifier;
        }

        initialEmail ??= user.email;
        if (initialUsername.trim().isEmpty) {
          initialUsername = "User_${user.uid.substring(0, 6)}";
        }

        debugPrint("Creating basic profile for new user: ${user.uid}");
        await docRef.set({
          'uid': user.uid,
          'username': initialUsername,
          'email': initialEmail,
          'phoneNumber': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'fullName': '',
          'dateOfBirth': null,
          'address': '',
        });
        return true;
      } else {
        debugPrint("User profile already exists for: ${user.uid}");
        return false;
      }
    } on FirebaseException catch (e) {
      debugPrint("Error checking/creating user profile for ${user.uid}: $e");
      rethrow;
    }
  }
}
