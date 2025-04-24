// lib/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode or logging

/// Service class for interacting with user profile data in Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'users'; // Firestore collection name for users

  /// Retrieves a real-time stream of the user's document snapshot.
  ///
  /// [uid] The unique ID of the user.
  /// Returns a stream that emits the document snapshot whenever the data changes.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    // No try-catch needed here as Stream handles errors via its error channel.
    return _db.collection(_collectionPath).doc(uid).snapshots();
  }

  /// Fetches the user's document data once.
  ///
  /// [uid] The unique ID of the user.
  /// Returns a Future containing the document snapshot.
  /// Throws a FirebaseException if the fetch fails.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    try {
      return await _db.collection(_collectionPath).doc(uid).get();
    } on FirebaseException catch (e) {
      // Log the error or handle it as needed
      debugPrint("Error fetching user data for $uid: $e");
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  /// Updates the username for a specific user.
  ///
  /// [uid] The unique ID of the user.
  /// [newUsername] The new username string.
  /// Throws a FirebaseException if the update fails.
  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      await _db.collection(_collectionPath).doc(uid).update({
        'username': newUsername,
        'updatedAt': FieldValue.serverTimestamp(), // Track updates
      });
      debugPrint("Username updated successfully for $uid.");
    } on FirebaseException catch (e) {
      debugPrint("Error updating username for $uid: $e");
      rethrow;
    }
  }

  /// Updates a specific field in the user's profile document.
  ///
  /// [uid] The unique ID of the user.
  /// [field] The key of the field to update (e.g., 'fullName', 'address').
  /// [value] The new value for the field.
  /// Throws a FirebaseException if the update fails.
  Future<void> updateUserProfileField(
    String uid,
    String field,
    dynamic value,
  ) async {
    // Basic validation: prevent updating protected fields if necessary
    // if (field == 'email' || field == 'createdAt') {
    //   debugPrint("Attempted to update protected field '$field'. Denied.");
    //   return; // Or throw an error
    // }

    try {
      await _db.collection(_collectionPath).doc(uid).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(), // Track updates
      });
      debugPrint("Field '$field' updated successfully for $uid.");
    } on FirebaseException catch (e) {
      debugPrint("Error updating field '$field' for $uid: $e");
      rethrow;
    }
  }

  /// Creates a basic user profile document in Firestore if one doesn't already exist.
  /// Typically called after user registration (especially phone auth).
  ///
  /// [user] The authenticated [User] object from Firebase Auth.
  /// [identifier] The primary identifier used for sign-up (e.g., email or phone number).
  /// Returns `true` if a new profile was created, `false` if it already existed.
  /// Throws a FirebaseException if the operation fails.
  Future<bool> createBasicUserProfileIfNeeded(
    User user,
    String identifier,
  ) async {
    final docRef = _db.collection(_collectionPath).doc(user.uid);

    try {
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Document doesn't exist, create a basic profile
        String initialUsername;
        String? initialEmail;

        // Determine if identifier is email or phone
        // Note: Using phone number or email prefix as default username might
        // not be ideal for all applications (privacy, uniqueness).
        // Consider prompting user or using a placeholder like "User_abc12".
        if (identifier.contains('@') && identifier.length > 1) {
          initialEmail = identifier;
          initialUsername = identifier.split('@')[0];
        } else {
          initialEmail = null; // Phone users might not have email initially
          initialUsername = identifier; // Use phone number or other identifier
        }

        // Use user.email from Auth provider as a fallback if available
        initialEmail ??= user.email;
        // Ensure username is not empty if identifier logic fails somehow
        if (initialUsername.trim().isEmpty) {
          initialUsername =
              "User_${user.uid.substring(0, 6)}"; // Fallback username
        }

        debugPrint("Creating basic profile for new user: ${user.uid}");
        await docRef.set({
          'uid': user.uid, // Store UID in the document as well
          'username': initialUsername,
          'email': initialEmail, // Can be null
          'phoneNumber': user.phoneNumber, // Can be null
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          // Add other default fields as needed (e.g., fullName: '', address: '')
          'fullName': '',
          'dateOfBirth': null, // Or FieldValue.serverTimestamp() if relevant
          'address': '',
        });
        return true; // Profile was created
      } else {
        debugPrint("User profile already exists for: ${user.uid}");
        // Optionally update 'lastLogin' or check for missing fields here
        // await docRef.update({'lastLogin': FieldValue.serverTimestamp()});
        return false; // Profile already existed
      }
    } on FirebaseException catch (e) {
      debugPrint("Error checking/creating user profile for ${user.uid}: $e");
      rethrow;
    }
  }

  // Add other specific methods if needed, e.g.:
  // Future<void> updateUserAddress(String uid, String address) async { ... }
  // Future<void> updateUserDateOfBirth(String uid, Timestamp dob) async { ... }
}
