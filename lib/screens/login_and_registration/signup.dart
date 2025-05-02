// screens/login_and_registration/signup.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication.
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore database.
import 'package:provider/provider.dart'; // Import Provider for state management.
import 'package:local_plant_identification/main.dart'; // Import main for LocaleProvider (assuming it's defined there).
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations for localization.

// A screen for user registration (Sign Up).
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Global key for the form to manage validation.
  final _signupFormKey = GlobalKey<FormState>();

  // Flags to toggle password visibility.
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Text editing controllers for the input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();

  // Removed state variables for typed values, use controllers directly.

  @override
  void dispose() {
    // Dispose of the controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }

  // Asynchronously handles the user registration process.
  Future<void> _register() async {
    // Validate the form. If invalid, stop the registration process.
    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    // Get the trimmed text from the controllers.
    final String typedEmail = _emailController.text.trim();
    final String typedPassword = _passwordController.text;
    final String typedUsername = _usernameController.text.trim();
    final String typedFullname = _fullnameController.text.trim();

    try {
      // Create a new user with email and password using Firebase Authentication.
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: typedEmail,
        password: typedPassword,
      );
      User? user = credential.user; // Get the created user object.

      // If a user object is returned, save their details to Firestore.
      if (user != null) {
        DocumentReference userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid); // Get the document reference for the new user.
        await userDoc.set({
          'username': typedUsername,
          'fullname': typedFullname, // Corrected key to 'fullname'.
          'email': typedEmail,
          'createdAt': FieldValue
              .serverTimestamp(), // Add server timestamp for creation time.
          'points': 0, // Initialize points to 0.
          'gallery': [], // Initialize gallery as an empty list.
          'favoritePlantIds': [], // Initialize favorites as an empty list.
          // Initialize other fields like dateOfBirth and address.
          'dateOfBirth': null,
          'address': '',
        });
        // Optionally update Firebase Auth profile (e.g., display name).
        // await user.updateDisplayName(typedFullname);
      }

      // If the widget is still mounted, show a success message and navigate to the login screen.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // Hardcoded English Success Message as per previous instructions.
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to the login screen and remove all previous routes from the stack.
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      // Catch and handle Firebase Authentication specific errors.
      String message;
      // Hardcoded English error messages based on error codes.
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak (min 6 characters).';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Unable to register. Please try again.';
      }
      print(
          'FirebaseAuthException: ${e.code} - ${e.message}'); // Log the error details.
      // If the widget is still mounted, show a SnackBar with the hardcoded error message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message), // Display the hardcoded error message.
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Catch and handle any other general errors during registration or Firestore save.
      print(
          "Error during registration or Firestore save: $e"); // Log the error.
      // If the widget is still mounted, show a SnackBar with a generic hardcoded error message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // Hardcoded English Error Message.
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    // Get the AppLocalizations instance for accessing localized strings.
    final l10n = AppLocalizations.of(context)!;

    return CustomScaffold(
      // Custom background scaffold.
      child: Stack(
        // Use a Stack to position the language selection button.
        children: [
          Column(
            children: [
              const Expanded(
                  flex: 1, child: SizedBox(height: 10)), // Space at the top.
              Expanded(
                flex: 9, // Adjusted flex to give more space for the content.
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                      25.0, 40.0, 25.0, 20.0), // Padding inside the container.
                  decoration: const BoxDecoration(
                    color: Colors.white, // White background for the form area.
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
                          _signupFormKey, // Associate the GlobalKey with the form.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center column children.
                        children: [
                          // Localized title for the sign-up form.
                          Text(
                            l10n.signupCreateAccountTitle, // Use the localized key.
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme
                                  .primary, // Use primary color from scheme.
                            ),
                          ),
                          const SizedBox(height: 30.0), // Vertical space.

                          // Full Name input field.
                          TextFormField(
                            controller:
                                _fullnameController, // Associate the controller.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Hardcoded English Validation Message.
                                return 'Please enter your Full Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  l10n.signupFullNameLabel, // Localized label.
                              hintText: l10n
                                  .signupFullNameHint, // Localized hint text.
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            keyboardType:
                                TextInputType.name, // Keyboard for names.
                          ),
                          const SizedBox(height: 20.0), // Vertical space.

                          // Username input field.
                          TextFormField(
                            controller:
                                _usernameController, // Associate the controller.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Hardcoded English Validation Message.
                                return 'Please enter a Username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  l10n.signupUsernameLabel, // Localized label.
                              hintText: l10n
                                  .signupUsernameHint, // Localized hint text.
                              prefixIcon:
                                  const Icon(Icons.account_circle_outlined),
                            ),
                          ),
                          const SizedBox(height: 20.0), // Vertical space.

                          // Email input field.
                          TextFormField(
                            controller:
                                _emailController, // Associate the controller.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Hardcoded English Validation Message.
                                return 'Please enter Email';
                              }
                              // Simple email format validation.
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                // Hardcoded English Validation Message.
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  l10n.signupEmailLabel, // Localized label.
                              hintText:
                                  l10n.signupEmailHint, // Localized hint text.
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType
                                .emailAddress, // Keyboard for emails.
                          ),
                          const SizedBox(height: 20.0), // Vertical space.

                          // Password input field.
                          TextFormField(
                            controller:
                                _passwordController, // Associate the controller.
                            obscureText:
                                _obscurePassword, // Toggle password visibility.
                            obscuringCharacter:
                                '*', // Character to obscure password.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Hardcoded English Validation Message.
                                return 'Please enter Password';
                              }
                              if (value.length < 6) {
                                // Hardcoded English Validation Message.
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  l10n.signupPasswordLabel, // Localized label.
                              hintText: l10n
                                  .signupPasswordHint, // Localized hint text.
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Toggle icon based on visibility state.
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  // Toggle the password visibility state.
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0), // Vertical space.

                          // Confirm Password input field.
                          TextFormField(
                            controller:
                                _confirmPasswordController, // Associate the controller.
                            obscureText:
                                _obscureConfirmPassword, // Toggle password visibility.
                            obscuringCharacter:
                                '*', // Character to obscure password.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Hardcoded English Validation Message.
                                return 'Please confirm your Password';
                              }
                              // Check if the confirmed password matches the password field.
                              if (value != _passwordController.text) {
                                // Hardcoded English Validation Message.
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: l10n
                                  .signupConfirmPasswordLabel, // Localized label.
                              hintText: l10n
                                  .signupConfirmPasswordHint, // Localized hint text.
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Toggle icon based on visibility state.
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  // Toggle the confirm password visibility state.
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0), // Vertical space.

                          // Sign Up button.
                          SizedBox(
                            width: double
                                .infinity, // Make the button take full width.
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Green background color.
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ), // Padding for the button.
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Rounded corners.
                                ),
                              ),
                              onPressed:
                                  _register, // Call the _register function when pressed.
                              child: Text(
                                l10n.signupSignUpButton, // Localized text for "Sign Up".
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25.0), // Vertical space.

                          // "Already have an account?" link to the login screen.
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center the row's children.
                            children: [
                              Text(l10n
                                  .signupHaveAccountPrompt), // Localized prompt text.
                              TextButton(
                                onPressed: () {
                                  // Navigate to the login screen, replacing the current route.
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                                child: Text(l10n
                                    .signupSignInLink), // Localized "Sign In" link text.
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0), // Vertical space.
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Language selection button positioned at the top right.
          Positioned(
            top: 10,
            right: 10,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.language,
                  color: Colors.white), // Language icon (white color).
              tooltip: 'Select Language', // Hardcoded tooltip.
              onSelected: (String langCode) {
                // Added LocaleProvider logic to update the app's locale.
                print('Language selected: $langCode');
                // Get the provider without listening in the callback.
                final localeProvider = Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                );
                // Set the new locale using the provider.
                localeProvider.setLocale(Locale(langCode));
              },
              itemBuilder: (BuildContext context) {
                // Menu item text remains hardcoded English as per previous instructions.
                return [
                  const PopupMenuItem<String>(
                    value: 'en',
                    child: Text('English'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'ms',
                    child: Text('Malay'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'zh',
                    child: Text('Chinese'),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}
