// screens/login_and_registration/forgetpassword.dart
import 'package:flutter/material.dart';
// Removed: import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  // Background Image URL (copied from CustomScaffold reference)
  static const String _backgroundImageUrl =
      'https://fra.cloud.appwrite.io/v1/storage/buckets/67fc68bc003416307fcf/files/67ff1310002143dd0c24/view?project=67f50b9d003441bfb6ac&mode=admin';

  Future<void> _resetPassword() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      // --- Hardcoded English Success Message ---
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Password reset email sent successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      // --- Hardcoded English Error Message ---
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Use a standard Scaffold directly
    return Scaffold(
      // Define the AppBar specific to this screen
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle), // Localized AppBar Title
        backgroundColor: Colors.transparent, // Keep AppBar transparent
        elevation: 0, // Remove shadow
        iconTheme:
            const IconThemeData(color: Colors.white), // Back button color
        titleTextStyle:
            const TextStyle(color: Colors.white, fontSize: 20), // Title color
      ),
      // Extend body behind the AppBar to show the background
      extendBodyBehindAppBar: true,
      // Use a Stack for the background image and content
      body: Stack(
        children: [
          // Background Image (copied structure from CustomScaffold)
          Positioned.fill(
            child: Image.network(
              _backgroundImageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print("Error loading background image: $error");
                return Container(
                  color: Colors.blueGrey[900], // Fallback color
                  child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.white30)),
                );
              },
            ),
          ),
          // SafeArea ensures content avoids notches/status bars
          SafeArea(
            child: Column(
              children: [
                // Spacer to push content down below the transparent AppBar area
                // Adjust height as needed based on AppBar height
                const SizedBox(height: kToolbarHeight + 20),
                Expanded(
                  // Removed Expanded flex values as they are less predictable here
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        25.0, 30.0, 25.0, 20.0), // Adjusted top padding
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _forgetPasswordFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Fit content
                          children: [
                            // Title is now in AppBar
                            const SizedBox(
                                height: 20.0), // Initial spacing inside card
                            TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Email'; // Hardcoded
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email'; // Hardcoded
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText:
                                    l10n.forgotPasswordEmailLabel, // Localized
                                labelStyle: TextStyle(
                                  color: lightColorScheme.primary,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 30.0),
                            ElevatedButton(
                              onPressed: () async {
                                if (_forgetPasswordFormKey.currentState!
                                    .validate()) {
                                  await _resetPassword();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 80,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text(
                                l10n.forgotPasswordResetButton, // Localized
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                                height: 20.0), // Bottom padding inside card
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
