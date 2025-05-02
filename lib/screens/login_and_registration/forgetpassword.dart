// screens/login_and_registration/forgetpassword.dart
import 'package:flutter/material.dart';
// Removed: import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication.
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations for localization.

// A screen for users to reset their password.
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  // Global key for the form to manage validation.
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  // Text editing controller for the email input field.
  final TextEditingController _emailController = TextEditingController();

  // Background Image URL (copied from CustomScaffold reference)
  static const String _backgroundImageUrl =
      'https://fra.cloud.appwrite.io/v1/storage/buckets/67fc68bc003416307fcf/files/67ff1310002143dd0c24/view?project=67f50b9d003441bfb6ac&mode=admin';

  // Asynchronously sends a password reset email to the provided email address.
  Future<void> _resetPassword() async {
    // Check if the widget is still mounted before proceeding.
    if (!mounted) return;
    // Get the ScaffoldMessenger state for showing SnackBars.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Send the password reset email using Firebase Authentication.
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text
            .trim(), // Use the trimmed email from the controller.
      );
      // Check if the widget is still mounted before showing the success message and navigating.
      if (!mounted) return;
      // Hardcoded English Success Message as per previous instructions.
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Password reset email sent successfully')),
      );
      // Pop the current screen (ForgetPassword) from the navigation stack.
      Navigator.pop(context);
    } catch (e) {
      // Catch and handle any errors during the process.
      // Check if the widget is still mounted before showing the error message.
      if (!mounted) return;
      // Hardcoded English Error Message.
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content:
                Text('Error: ${e.toString()}')), // Display the error message.
      );
    }
  }

  @override
  void dispose() {
    // Dispose of the controller to prevent memory leaks.
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    // Get the AppLocalizations instance for accessing localized strings.
    final l10n = AppLocalizations.of(context)!;

    // Use a standard Scaffold directly instead of CustomScaffold.
    return Scaffold(
      // Define the AppBar specific to this screen.
      appBar: AppBar(
        title: Text(
            l10n.forgotPasswordTitle), // Localized AppBar Title using the key.
        backgroundColor: Colors
            .transparent, // Keep AppBar background transparent to show the body behind it.
        elevation: 0, // Remove shadow from the AppBar.
        iconTheme: const IconThemeData(
            color: Colors
                .white), // Set the color of the back button icon to white.
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20), // Set the style for the AppBar title text.
      ),
      // Extend the body behind the AppBar to allow the background image to cover the full screen height.
      extendBodyBehindAppBar: true,
      // Use a Stack to layer the background image and the content.
      body: Stack(
        children: [
          // Background Image layer (copied structure from CustomScaffold).
          Positioned.fill(
            child: Image.network(
              _backgroundImageUrl, // Use the static background image URL.
              fit: BoxFit.cover, // Cover the entire area of the Stack.
              // Builder for showing a loading indicator while the image loads.
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color:
                      Colors.grey[800], // Dark grey background while loading.
                  child: const Center(
                      child:
                          CircularProgressIndicator()), // Centered loading spinner.
                );
              },
              // Builder for handling image loading errors.
              errorBuilder: (context, error, stackTrace) {
                print(
                    "Error loading background image: $error"); // Log the error.
                return Container(
                  color: Colors
                      .blueGrey[900], // Fallback dark blue-grey color on error.
                  child: const Center(
                      child: Icon(Icons.error_outline,
                          color: Colors.white30)), // Centered error icon.
                );
              },
            ),
          ),
          // SafeArea ensures content avoids notches and status bars, providing proper spacing.
          SafeArea(
            child: Column(
              children: [
                // Spacer to push content down below the transparent AppBar area.
                // kToolbarHeight provides the standard height of an AppBar.
                const SizedBox(height: kToolbarHeight + 20),
                Expanded(
                  // The main content area, taking up the remaining vertical space.
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0,
                        20.0), // Adjusted top padding for spacing below the Spacer.
                    decoration: const BoxDecoration(
                      color:
                          Colors.white, // White background for the form area.
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(40.0), // Rounded top-left corner.
                        topRight:
                            Radius.circular(40.0), // Rounded top-right corner.
                      ),
                    ),
                    child: SingleChildScrollView(
                      // Make the content scrollable.
                      child: Form(
                        key:
                            _forgetPasswordFormKey, // Associate the GlobalKey with the form.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Center column children horizontally.
                          mainAxisSize: MainAxisSize
                              .min, // Make the column fit its content vertically.
                          children: [
                            // Title is now in AppBar, so this space is added for visual padding inside the card.
                            const SizedBox(
                                height:
                                    20.0), // Initial spacing inside the card.
                            // Email input field.
                            TextFormField(
                              controller:
                                  _emailController, // Associate the controller.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Email'; // Hardcoded validation message.
                                }
                                // Basic email format validation using a regex.
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email'; // Hardcoded validation message.
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: l10n
                                    .forgotPasswordEmailLabel, // Localized label text.
                                labelStyle: TextStyle(
                                  color: lightColorScheme
                                      .primary, // Label text color from theme.
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme
                                        .primary, // Border color when focused.
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme
                                        .primary, // Border color when enabled.
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType
                                  .emailAddress, // Keyboard for email input.
                            ),
                            const SizedBox(height: 30.0), // Vertical space.
                            // Reset Password button.
                            ElevatedButton(
                              onPressed: () async {
                                // Validate the form before attempting to reset the password.
                                if (_forgetPasswordFormKey.currentState!
                                    .validate()) {
                                  await _resetPassword(); // Call the reset password function.
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Green background color.
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 80,
                                  vertical: 15,
                                ), // Padding for the button.
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners.
                                ),
                                minimumSize: const Size(double.infinity,
                                    50), // Button takes full width with minimum height.
                              ),
                              child: Text(
                                l10n.forgotPasswordResetButton, // Localized text for the button.
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white, // White text color.
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:
                                    20.0), // Bottom padding inside the card.
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
