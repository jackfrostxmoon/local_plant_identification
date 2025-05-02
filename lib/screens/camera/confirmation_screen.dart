// screens/camera/confirmation_screen.dart (Full modified code)

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'dart:typed_data'; // Import Uint8List
import 'package:local_plant_identification/screens/profile/user_profile_screen.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmationScreen extends StatefulWidget {
  // Modify constructor parameters
  final String? imagePath; // Path for mobile (nullable)
  final Uint8List? imageBytes; // Bytes for web (nullable)
  final String plantName;
  final double plantProbability;

  const ConfirmationScreen({
    super.key,
    this.imagePath, // Make nullable
    this.imageBytes, // Add nullable bytes
    required this.plantName,
    required this.plantProbability,
  }) : assert(
            imagePath != null || imageBytes != null, // Ensure one is provided
            'Either imagePath or imageBytes must be provided');

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isUploading = false;
  final AppwriteService _appwriteService = AppwriteService();

  Future<void> _uploadAndConfirm() async {
    if (_isUploading || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in.", isError: true); // Hardcoded error
      return;
    }

    // --- Check if image data is available ---
    if ((kIsWeb && widget.imageBytes == null) ||
        (!kIsWeb && widget.imagePath == null)) {
      _showSnackBar("Image data is missing.", isError: true); // Hardcoded error
      return;
    }
    // --- End check ---

    setState(() => _isUploading = true);

    String? uploadedFileId;
    try {
      String fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
      InputFile inputFile;

      // --- Use correct InputFile constructor based on platform ---
      if (kIsWeb) {
        // Use bytes for web
        inputFile = InputFile.fromBytes(
          bytes: widget.imageBytes!, // We asserted it's not null above
          filename: fileName,
        );
      } else {
        // Use path for mobile
        inputFile = InputFile.fromPath(
            path: widget.imagePath!, // We asserted it's not null above
            filename: fileName);
      }
      // --- End platform check ---

      print(
          "Uploading to Appwrite Storage: ${AppwriteConfig.plantImagesStorageId}");
      final result = await _appwriteService.storage.createFile(
        bucketId: AppwriteConfig.plantImagesStorageId,
        fileId: ID.unique(),
        file: inputFile,
      );
      uploadedFileId = result.$id;
      print("Appwrite upload successful, File ID: $uploadedFileId");

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set(
        {
          'gallery': FieldValue.arrayUnion([uploadedFileId])
        },
        SetOptions(merge: true),
      );
      print("Firestore update successful for user ${user.uid}");

      if (!mounted) return;
      _showSnackBar(
          "Image confirmed and saved to gallery!"); // Hardcoded success

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
      );
    } on AppwriteException catch (e) {
      print("Appwrite Error during upload: ${e.toString()}");
      if (!mounted) return;
      _showSnackBar("Appwrite Error: ${e.message ?? e.toString()}",
          isError: true); // Hardcoded error
    } catch (e) {
      print("Generic Error during upload/save: ${e.toString()}");
      if (!mounted) return;
      _showSnackBar("Failed to save image: ${e.toString()}",
          isError: true); // Hardcoded error
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.green, Colors.teal],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App bar section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.green.shade700,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                    Text(
                      l10n.confirmationAppBarTitle, // Localized
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Plant name and probability
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.confirmationPlantNamePrefix}${widget.plantName}', // Localized
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.confirmationProbabilityPrefix}${(widget.plantProbability * 100).toStringAsFixed(2)}%', // Localized
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Image preview (Handles both path and bytes)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: ClipRRect(
                    child: kIsWeb
                        ? (widget.imageBytes !=
                                null // Check bytes first for web
                            ? Image.memory(
                                widget.imageBytes!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.error)),
                              )
                            : const Center(
                                child: Icon(Icons
                                    .image_not_supported))) // Placeholder if no bytes
                        : (widget.imagePath !=
                                null // Check path first for mobile
                            ? Image.file(
                                io.File(widget.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.error)),
                              )
                            : const Center(
                                child: Icon(Icons
                                    .image_not_supported))), // Placeholder if no path
                  ),
                ),
              ),

              // Buttons
              Container(
                margin: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isUploading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Text(l10n.confirmationCancelButton), // Localized
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Confirm button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _uploadAndConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.green.shade300,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(l10n.confirmationConfirmButton), // Localized
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
