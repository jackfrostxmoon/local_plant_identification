import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart'; // Still needed for AppwriteException, ID, InputFile
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Import the new widgets
import 'image_picker_uploader.dart';
import 'image_grid.dart';

// The main screen widget for displaying and managing the user's image gallery.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

// The state management for the GalleryScreen.
class _GalleryScreenState extends State<GalleryScreen> {
  // Getter to access localized strings using the context.
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  // Instance of the Appwrite service for interacting with Appwrite.
  final AppwriteService _appwriteService = AppwriteService();
  // Holds the bytes of the selected image for web uploads.
  Uint8List? _imageBytes;
  // Holds the path of the selected image for mobile uploads.
  String? _imagePath;
  // A list of image IDs stored in Appwrite.
  List<dynamic> _imageIds = [];
  // Flag to indicate if images are currently being loaded.
  bool _isLoadingImages = true;
  // Flag to indicate if an image is currently being uploaded.
  bool _isUploading = false;
  // Flag to indicate if an image is currently being deleted.
  bool _isDeleting = false; // Keep track of deletion state

  @override
  void initState() {
    super.initState();
    // Load images when the screen is initialized.
    _loadImages();
  }

  // --- Helper Methods (Keep as they are) ---
  // Displays a SnackBar with a given message.
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

  // Asynchronously loads the list of image IDs from Firestore.
  Future<void> _loadImages() async {
    if (!mounted) return;
    // Set loading state and clear existing image IDs.
    setState(() {
      _isLoadingImages = true;
      _imageIds = [];
    });

    // Get the current authenticated user from Firebase.
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in.", isError: true);
      if (mounted) setState(() => _isLoadingImages = false);
      return;
    }

    try {
      // Fetch the user's document from Firestore.
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        // Check if the document and gallery field exist.
        if (userDoc.exists && userDoc.data() != null) {
          final galleryData = userDoc.data()!['gallery'];
          // Keep the filtering logic here or move to ImageGrid if preferred
          // If galleryData is a list, update the local image IDs.
          if (galleryData is List) {
            _imageIds = galleryData; // Pass raw list to ImageGrid
            // _imageIds = galleryData.where((id) => id is String && id.isNotEmpty).toList();
          } else {
            // If galleryData is not a list, initialize with an empty list.
            _imageIds = [];
          }
          print("Loaded image IDs: $_imageIds");
        } else {
          print("User document or gallery field does not exist.");
          // If the document or field doesn't exist, initialize with an empty list.
          _imageIds = [];
        }
      }
    } catch (e) {
      // Handle any errors during Firestore operations.
      print("Firestore Error loading images: ${e.toString()}");
      _showSnackBar("Error loading image list: ${e.toString()}", isError: true);
      if (mounted) _imageIds = [];
    } finally {
      // Always set loading state to false after the operation.
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  // Allows the user to pick an image using a file picker.
  Future<void> pickImage() async {
    // Reset previous selection regardless of platform.
    setState(() {
      _imageBytes = null;
      _imagePath = null;
    });

    try {
      // Use FilePicker to select an image file.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb, // Crucial for web to get bytes
        allowMultiple: false,
      );

      // Process the selected file if a result is obtained.
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (!mounted) return; // Check mounted after await

        // Update the state based on the platform (web or mobile).
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
        // Show a message if image selection is cancelled.
        _showSnackBar("Image selection cancelled.");
      }
    } catch (e) {
      // Handle any errors during the image picking process.
      print("Error picking image: ${e.toString()}");
      _showSnackBar("Error picking image: ${e.toString()}", isError: true);
    }
  }

  // Uploads the selected image to Appwrite storage and updates Firestore.
  Future<void> uploadImage() async {
    // Check if an image has been selected based on the platform.
    if ((kIsWeb && _imageBytes == null) || (!kIsWeb && _imagePath == null)) {
      _showSnackBar("Please select an image first.", isError: true);
      return;
    }
    // Prevent concurrent uploads or actions if the widget is not mounted.
    if (_isUploading || !mounted) return;

    // Get the current authenticated user.
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in.", isError: true);
      return;
    }

    // Set the uploading state to true.
    setState(() => _isUploading = true);

    String? uploadedFileId;
    try {
      // Generate a unique filename for the uploaded image.
      String fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
      InputFile inputFile;

      // Create an InputFile based on the platform.
      if (kIsWeb) {
        inputFile = InputFile.fromBytes(
          bytes: _imageBytes!,
          filename: fileName,
        );
      } else {
        inputFile = InputFile.fromPath(path: _imagePath!, filename: fileName);
      }

      print("Uploading to bucket: ${AppwriteConfig.plantImagesStorageId}");
      // Upload the file to Appwrite storage.
      final result = await _appwriteService.storage.createFile(
        bucketId: AppwriteConfig.plantImagesStorageId,
        fileId: ID.unique(), // Generate a unique ID for the file in Appwrite.
        file: inputFile,
      );
      uploadedFileId = result.$id;
      print("Appwrite upload successful, File ID: $uploadedFileId");

      // Get a reference to the user's document in Firestore.
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      // Add the uploaded file ID to the user's gallery list in Firestore.
      await userDoc.set({
        'gallery': FieldValue.arrayUnion([uploadedFileId]),
      }, SetOptions(merge: true));
      print("Firestore update successful for user ${user.uid}");

      if (mounted) {
        // Update the local state with the new image ID and clear the selection.
        setState(() {
          _imageIds.add(uploadedFileId); // Add to local list immediately
          _imageBytes = null; // Clear selection
          _imagePath = null;
        });
        _showSnackBar("Image uploaded successfully!");
      }
    } on AppwriteException catch (e) {
      // Handle specific Appwrite errors during upload.
      print("Appwrite Error during upload: ${e.toString()}");
      _showSnackBar(
        "Appwrite Error: ${e.message ?? e.toString()}",
        isError: true,
      );
    } catch (e) {
      // Handle any other generic errors during upload.
      print("Generic Error during upload: ${e.toString()}");
      _showSnackBar("Error uploading image: ${e.toString()}", isError: true);
    } finally {
      // Always set the uploading state to false after the operation.
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // Deletes an image from Appwrite storage and removes its ID from Firestore.
  Future<void> deleteImage(String imageId) async {
    // Prevent concurrent deletions or actions if the widget is not mounted.
    if (_isDeleting || !mounted) return; // Prevent concurrent deletions

    // Get the current authenticated user.
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in.", isError: true);
      return;
    }

    // Set the deleting state to true.
    setState(() => _isDeleting = true);

    try {
      print(
        "Deleting file $imageId from bucket ${AppwriteConfig.plantImagesStorageId}",
      );
      // Delete the file from Appwrite storage.
      await _appwriteService.storage.deleteFile(
        bucketId: AppwriteConfig.plantImagesStorageId,
        fileId: imageId,
      );
      print("Appwrite delete successful for $imageId");

      // Get a reference to the user's document in Firestore.
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      // Remove the image ID from the user's gallery list in Firestore.
      await userDoc.update({
        'gallery': FieldValue.arrayRemove([imageId]),
      });
      print("Firestore remove successful for $imageId");

      if (mounted) {
        // Remove the image ID from the local state.
        setState(() {
          // Ensure the ID exists before removing
          _imageIds.removeWhere((id) => id == imageId);
        });
        _showSnackBar("Image deleted successfully!");
      }
    } on AppwriteException catch (e) {
      // Handle specific Appwrite errors during deletion.
      print("Appwrite Error during delete: ${e.toString()}");
      _showSnackBar(
        "Appwrite Error deleting file: ${e.message ?? e.toString()}",
        isError: true,
      );
    } catch (e) {
      // Handle any other generic errors during deletion.
      print("Generic Error during delete: ${e.toString()}");
      _showSnackBar("Error deleting image: ${e.toString()}", isError: true);
    } finally {
      // Always set the deleting state to false after the operation.
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // --- Build Method (Simplified) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.galleryAppBarTitle),
        backgroundColor: const Color(0xFFA8E6A2),
        actions: [
          // Refresh button remains useful
          IconButton(
            icon: const Icon(Icons.refresh),
            // Disable refresh while loading/uploading/deleting
            onPressed: _isLoadingImages || _isUploading || _isDeleting
                ? null
                : _loadImages,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Use the ImagePickerUploader Widget ---
          // Widget for picking and uploading images.
          ImagePickerUploader(
            imageBytes: _imageBytes, // Pass selected image bytes.
            imagePath: _imagePath, // Pass selected image path.
            isUploading: _isUploading, // Pass uploading state.
            onPickImage: pickImage, // Pass the method reference for picking.
            onUploadImage:
                uploadImage, // Pass the method reference for uploading.
          ),

          const Divider(height: 20, thickness: 1),

          // --- Use the ImageGrid Widget ---
          // Widget for displaying the image gallery.
          Expanded(
            child: ImageGrid(
              isLoading: _isLoadingImages, // Pass loading state.
              imageIds: _imageIds, // Pass the list of image IDs.
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
