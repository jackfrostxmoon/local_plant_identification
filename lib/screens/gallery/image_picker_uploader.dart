import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImagePickerUploader extends StatelessWidget {
  final Uint8List? imageBytes; // For Web
  final String? imagePath; // For Mobile
  final bool isUploading;
  final VoidCallback onPickImage;
  final VoidCallback onUploadImage;

  const ImagePickerUploader({
    super.key,
    required this.imageBytes,
    required this.imagePath,
    required this.isUploading,
    required this.onPickImage,
    required this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        (kIsWeb && imageBytes != null) || (!kIsWeb && imagePath != null);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- Image Preview ---
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? (imageBytes != null
                      ? Image.memory(
                          imageBytes!,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        )
                      : Text(AppLocalizations.of(context)!
                          .imagePickerNoImageSelected))
                  : (imagePath != null
                      ? Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        )
                      : Text(AppLocalizations.of(context)!
                          .imagePickerNoImageSelected)),
            ),
          ),
          const SizedBox(height: 10),

          // --- Action Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- Pick Image Button ---
              ElevatedButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.image_search, color: Colors.black),
                label: Text(
                  AppLocalizations.of(context)!.pickImageButtonLabel,
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),

              // --- Upload Image Button ---
              ElevatedButton.icon(
                onPressed: hasImage && !isUploading ? onUploadImage : null,
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white, // Spinner color on active button
                        ),
                      )
                    : const Icon(
                        Icons.cloud_upload,
                        color: Colors.black, // Icon color when enabled
                      ),
                label: Text(
                  isUploading
                      ? AppLocalizations.of(context)!.uploadingButtonLabel
                      : AppLocalizations.of(context)!.uploadImageButtonLabel,
                  style: const TextStyle(color: Colors.black), // Text color
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA8E6A2), // Normal background
                  foregroundColor: Colors.black, // Text/Icon color
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  disabledBackgroundColor:
                      Colors.grey.shade400, // Disabled background
                  disabledForegroundColor:
                      Colors.grey.shade700, // Disabled text/icon
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
