// screens/camera/camera_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:typed_data'; // Import Uint8List
import 'confirmation_screen.dart';
import 'api_integration.dart'; // Assuming this contains APIIntegration class
import 'models.dart'; // Assuming this contains Plant class

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final APIIntegration apiIntegration = APIIntegration();

  bool _isReady = false;
  bool _isProcessing = false;

  // Define the desired aspect ratio (Mobile Portrait)
  final double desiredAspectRatio = 9.0 / 16.0; // Portrait

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isEmpty) {
      print("Error: No cameras available!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("No cameras found on this device."), // Hardcoded error
          ));
        }
      });
    } else {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.high, // Keep high resolution for capture quality
      enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.jpeg, // Default is usually fine
    );

    try {
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    } on CameraException catch (e) {
      print("Error initializing camera: ${e.code} - ${e.description}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error initializing camera: ${e.description}"), // Hardcoded error
        ));
      }
    } catch (e) {
      print("Unexpected error initializing camera: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to initialize camera."), // Hardcoded error
        ));
      }
    }
  }

  @override
  void dispose() {
    // Check if controller was initialized before disposing
    // Use a local variable to avoid accessing potentially uninitialized _controller
    final controller = _controller;
    if (controller.value.isInitialized) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _photoshootAndIdentify() async {
    if (!_controller.value.isInitialized || !_isReady || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await _initializeControllerFuture;

      // Take picture - This captures based on ResolutionPreset,
      // likely NOT the 9:16 preview aspect ratio.
      final XFile file = await _controller.takePicture();

      // Read the image file into bytes
      Uint8List imageBytes = await file.readAsBytes();

      // --- Read bytes IF on web (already done above, keep for clarity) ---
      Uint8List? imageBytesForWeb;
      if (kIsWeb) {
        imageBytesForWeb = imageBytes; // Assign bytes read above
      }
      // --- End read bytes ---

      // 1. Start identifying first
      final String imageBase64 = base64Encode(imageBytes);
      final List<Plant>? identifiedPlants =
          await apiIntegration.identifyPlant(imageBase64);

      if (!mounted) return;

      if (identifiedPlants == null || identifiedPlants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No plant identified')), // Hardcoded
        );
        setState(() => _isProcessing = false);
        return;
      }

      final Plant topPlant = identifiedPlants.first;

      // 2. Navigate passing the correct data based on platform
      // NOTE: The image passed here (bytes or path) is the FULL image captured,
      // which might not be 9:16 like the preview.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            imageBytes: kIsWeb ? imageBytesForWeb : null,
            imagePath: kIsWeb ? null : file.path,
            plantName: topPlant.plantName,
            plantProbability: topPlant.probability,
          ),
        ),
      );
    } catch (e) {
      print('Error during photoshoot and identify: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process image')), // Hardcoded
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              // Custom AppBar-like section (optional)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.green,
                child: const Row(
                  children: [], // Add title or icons if needed
                ),
              ),

              // Camera preview section
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black54, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          _isReady &&
                          _controller.value.isInitialized) {
                        // Added check
                        // --- Start of Aspect Ratio Modification ---
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: OverflowBox(
                            // Allow the FittedBox to overflow for cropping
                            alignment: Alignment.center,
                            child: FittedBox(
                              // Scale the CameraPreview to cover the 9:16 area
                              fit: BoxFit.cover,
                              child: SizedBox(
                                // Force the container of CameraPreview to match the camera's aspect ratio
                                // This ensures FittedBox scales correctly without unnecessary stretching internally
                                width: MediaQuery.of(context)
                                    .size
                                    .width, // Use full width as reference
                                height: MediaQuery.of(context).size.width *
                                    _controller.value.aspectRatio,
                                child: AspectRatio(
                                  // *** Force the preview display area to 9:16 ***
                                  aspectRatio: desiredAspectRatio,
                                  child: CameraPreview(_controller),
                                ),
                              ),
                            ),
                          ),
                        );
                        // --- End of Aspect Ratio Modification ---
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Error initializing camera: ${snapshot.error}',
                                style: TextStyle(color: Colors.white)));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),

              // Photoshoot and Identify button section
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isReady && !_isProcessing
                      ? _photoshootAndIdentify
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.green.shade800,
                          ),
                        )
                      : const Text(
                          'Photoshoot', // Hardcoded button text
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
