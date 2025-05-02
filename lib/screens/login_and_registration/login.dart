// screens/login_and_registration/login.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:local_plant_identification/screens/login_and_registration/forgetpassword.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication.
import 'package:local_plant_identification/widgets/custom_text_field.dart';
import 'package:provider/provider.dart'; // Import Provider for state management.
import 'package:local_plant_identification/main.dart'; // Import main for LocaleProvider (assuming it's defined there).
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations for localization.

// A screen for user login.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Global key for the form to manage validation.
  final _loginFormKey = GlobalKey<FormState>();
  // Flag to remember the password (not implemented, but the UI element exists).
  bool rememberPassword = true;

  // Text editing controllers for email and password input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Asynchronously handles the user login process.
  Future<void> _login() async {
    // Get the trimmed email and password from the controllers.
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Validate the form. If invalid, stop the login process.
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    try {
      // Sign in the user with email and password using Firebase Authentication.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful and the widget is still mounted, navigate to the dashboard.
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      // Catch and handle Firebase Authentication specific errors.
      String errorMessage;
      // Hardcoded English error messages based on error codes.
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Wrong email or password provided.';
      } else {
        errorMessage =
            'An error occurred during login. Please try again.'; // Generic error message.
        print(
            'Firebase Auth Error: ${e.code} - ${e.message}'); // Log the error details.
      }
      // If the widget is still mounted, show a SnackBar with the hardcoded error message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent, // Red background for errors.
            content: Text(errorMessage), // Display the hardcoded error message.
            duration:
                const Duration(seconds: 4), // Duration the SnackBar is shown.
          ),
        );
      }
    } catch (e) {
      // Catch and handle any other general errors during the login process.
      print('Generic Login Error: $e'); // Log the generic error.
      // If the widget is still mounted, show a SnackBar with a generic hardcoded error message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent, // Red background for errors.
            // Hardcoded English error message.
            content: Text('An unexpected error occurred. Please try again.'),
            duration: Duration(seconds: 4), // Duration the SnackBar is shown.
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                flex: 7, // Adjusted flex to give more space for the content.
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                      25.0, 50.0, 25.0, 20.0), // Padding inside the container.
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
                          _loginFormKey, // Associate the GlobalKey with the form.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center column children.
                        children: [
                          // Localized welcome back title.
                          Text(
                            l10n.loginWelcomeBack, // Use the localized key.
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme
                                  .primary, // Use primary color from scheme.
                            ),
                          ),
                          const SizedBox(height: 40.0), // Vertical space.

                          // Email input field using a custom text field widget.
                          CustomTextField(
                            controller:
                                _emailController, // Associate the controller.
                            labelText: l10n.loginEmailLabel, // Localized label.
                            hintText:
                                l10n.loginEmailHint, // Localized hint text.
                            keyboardType: TextInputType
                                .emailAddress, // Keyboard for emails.
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
                          ),
                          const SizedBox(height: 25.0), // Vertical space.

                          // Password input field using a custom text field widget.
                          CustomTextField(
                            controller:
                                _passwordController, // Associate the controller.
                            labelText:
                                l10n.loginPasswordLabel, // Localized label.
                            hintText:
                                l10n.loginPasswordHint, // Localized hint text.
                            isPassword:
                                true, // Indicate that this is a password field.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Hardcoded English Validation Message.
                                return 'Please enter Password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25.0), // Vertical space.

                          // Row containing "Remember Me" checkbox and "Forgot Password" link.
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // Space out the children.
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value:
                                        rememberPassword, // Current state of the checkbox.
                                    onChanged: (bool? value) {
                                      // Update the state when the checkbox is tapped.
                                      setState(() {
                                        rememberPassword = value!;
                                      });
                                    },
                                    activeColor: lightColorScheme
                                        .primary, // Color when checked.
                                  ),
                                  Text(
                                    l10n.loginRememberMe, // Localized text for "Remember Me".
                                    style: const TextStyle(
                                        color: Colors.black45), // Text style.
                                  ),
                                ],
                              ),
                              // GestureDetector for the "Forgot Password" link.
                              GestureDetector(
                                onTap: () {
                                  // Navigate to the ForgetPassword screen.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPassword(),
                                    ),
                                  );
                                },
                                child: Text(
                                  l10n.loginForgotPassword, // Localized text for "Forgot Password?".
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme
                                        .primary, // Text color from scheme.
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25.0), // Vertical space.

                          // Sign In button.
                          SizedBox(
                            width: double
                                .infinity, // Make the button take full width.
                            child: ElevatedButton(
                              onPressed:
                                  _login, // Call the _login function when pressed.
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Green background color.
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 100,
                                  vertical: 15,
                                ), // Padding for the button.
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners.
                                ),
                              ),
                              child: Text(
                                l10n.loginSignInButton, // Localized text for "Sign In".
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0), // Vertical space.

                          // Row containing "Don't have an account?" prompt and "Sign Up" link.
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center the row's children.
                            children: [
                              Text(
                                l10n.loginNoAccountPrompt, // Localized prompt text.
                                style: const TextStyle(
                                    color: Colors.black45), // Text style.
                              ),
                              // GestureDetector for the "Sign Up" link.
                              GestureDetector(
                                onTap: () {
                                  // Navigate to the Signup screen.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const Signup(),
                                    ),
                                  );
                                },
                                child: Text(
                                  l10n.loginSignUpLink, // Localized text for "Sign Up".
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme
                                        .primary, // Text color from scheme.
                                  ),
                                ),
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
