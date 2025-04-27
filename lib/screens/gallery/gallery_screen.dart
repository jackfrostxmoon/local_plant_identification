import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart'; // Still needed for AppwriteException, ID, InputFile
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:file_picker/file_picker.dart';

// Import the new widgets
import 'image_picker_uploader.dart';
import 'image_grid.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Services and State remain the same
  final AppwriteService _appwriteService = AppwriteService();
  Uint8List? _imageBytes;
  String? _imagePath;
  List<dynamic> _imageIds = [];
  bool _isLoadingImages = true;
  bool _isUploading = false;
  bool _isDeleting = false; // Keep track of deletion state

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  // --- Helper Methods (Keep as they are) ---
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

  Future<void> _loadImages() async {
    if (!mounted) return;
    setState(() {
      _isLoadingImages = true;
      _imageIds = [];
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in.", isError: true);
      if (mounted) setState(() => _isLoadingImages = false);
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (mounted) {
        if (userDoc.exists && userDoc.data() != null) {
          final galleryData = userDoc.data()!['gallery'];
          // Keep the filtering logic here or move to ImageGrid if preferred
          if (galleryData is List) {
            _imageIds = galleryData; // Pass raw list to ImageGrid
            // _imageIds = galleryData.where((id) => id is String && id.isNotEmpty).toList();
          } else {
            _imageIds = [];
          }
          print("Loaded image IDs: $_imageIds");
        } else {
          print("User document or gallery field does not exist.");
          _imageIds = [];
        }
      }
    } catch (e) {
      print("Firestore Error loading images: ${e.toString()}");
      _showSnackBar("Error loading image list: ${e.toString()}", isError: true);
      if (mounted) _imageIds = [];
    } finally {
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  Future<void> pickImage() async {
    // Reset previous selection regardless of platform
    setState(() {
      _imageBytes = null;
      _imagePath = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb, // Crucial for web to get bytes
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (!mounted) return; // Check mounted after await

        setState(() {
          if (kIsWeb) {
            if (file.bytes != null) {
              _imageBytes = file.bytes;
              print("Web image picked: ${file.name}");
            } else {
              _showSnackBar("Failed to load image data on web.", isError: true);
            }
          } else {
            if (file.path != null) {
              _imagePath = file.path;
              print("Mobile image picked: ${file.path}");
            } else {
              _showSnackBar(
                "Failed to get image path on mobile.",
                isError: true,
              );
            }
          }
        });
      } else {
        _showSnackBar("Image selection cancelled.");
      }
    } catch (e) {
      print("Error picking image: ${e.toString()}");
      _showSnackBar("Error picking image: ${e.toString()}", isError: true);
    }
  }

  Future<void> uploadImage() async {
    if ((kIsWeb && _imageBytes == null) || (!kIsWeb && _imagePath == null)) {
      _showSnackBar("Please select an image first.", isError: true);
      return;
    }
    if (_isUploading || !mounted) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in.", isError: true);
      return;
    }

    setState(() => _isUploading = true);

    String? uploadedFileId;
    try {
      String fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
      InputFile inputFile;

      if (kIsWeb) {
        inputFile = InputFile.fromBytes(
          bytes: _imageBytes!,
          filename: fileName,
        );
      } else {
        inputFile = InputFile.fromPath(path: _imagePath!, filename: fileName);
      }

      print("Uploading to bucket: ${AppwriteConfig.plantImagesStorageId}");
      final result = await _appwriteService.storage.createFile(
        bucketId: AppwriteConfig.plantImagesStorageId,
        fileId: ID.unique(),
        file: inputFile,
      );
      uploadedFileId = result.$id;
      print("Appwrite upload successful, File ID: $uploadedFileId");

      DocumentReference userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await userDoc.set({
        'gallery': FieldValue.arrayUnion([uploadedFileId]),
      }, SetOptions(merge: true));
      print("Firestore update successful for user ${user.uid}");

      if (mounted) {
        setState(() {
          _imageIds.add(uploadedFileId); // Add to local list immediately
          _imageBytes = null; // Clear selection
          _imagePath = null;
        });
        _showSnackBar("Image uploaded successfully!");
      }
    } on AppwriteException catch (e) {
      print("Appwrite Error during upload: ${e.toString()}");
      _showSnackBar(
        "Appwrite Error: ${e.message ?? e.toString()}",
        isError: true,
      );
    } catch (e) {
      print("Generic Error during upload: ${e.toString()}");
      _showSnackBar("Error uploading image: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> deleteImage(String imageId) async {
    if (_isDeleting || !mounted) return; // Prevent concurrent deletions

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in.", isError: true);
      return;
    }

    setState(() => _isDeleting = true);

    try {
      print(
        "Deleting file $imageId from bucket ${AppwriteConfig.plantImagesStorageId}",
      );
      await _appwriteService.storage.deleteFile(
        bucketId: AppwriteConfig.plantImagesStorageId,
        fileId: imageId,
      );
      print("Appwrite delete successful for $imageId");

      DocumentReference userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await userDoc.update({
        'gallery': FieldValue.arrayRemove([imageId]),
      });
      print("Firestore remove successful for $imageId");

      if (mounted) {
        setState(() {
          // Ensure the ID exists before removing
          _imageIds.removeWhere((id) => id == imageId);
        });
        _showSnackBar("Image deleted successfully!");
      }
    } on AppwriteException catch (e) {
      print("Appwrite Error during delete: ${e.toString()}");
      _showSnackBar(
        "Appwrite Error deleting file: ${e.message ?? e.toString()}",
        isError: true,
      );
    } catch (e) {
      print("Generic Error during delete: ${e.toString()}");
      _showSnackBar("Error deleting image: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // --- Build Method (Simplified) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        backgroundColor: const Color(0xFFA8E6A2),
        actions: [
          // Refresh button remains useful
          IconButton(
            icon: const Icon(Icons.refresh),
            // Disable refresh while loading/uploading/deleting
            onPressed:
                _isLoadingImages || _isUploading || _isDeleting
                    ? null
                    : _loadImages,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Use the ImagePickerUploader Widget ---
          ImagePickerUploader(
            imageBytes: _imageBytes,
            imagePath: _imagePath,
            isUploading: _isUploading,
            onPickImage: pickImage, // Pass the method reference
            onUploadImage: uploadImage, // Pass the method reference
          ),

          const Divider(height: 20, thickness: 1),

          // --- Use the ImageGrid Widget ---
          Expanded(
            child: ImageGrid(
              isLoading: _isLoadingImages,
              imageIds: _imageIds,
              isDeleting: _isDeleting, // Pass deletion state down
              appwriteService: _appwriteService, // Pass the service instance
              onDeleteImage: deleteImage, // Pass the delete method reference
            ),
          ),
        ],
      ),
    );
  }
}
