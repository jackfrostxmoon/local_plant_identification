// screens/login_and_registration/signup.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:local_plant_identification/main.dart'; // Import main for LocaleProvider
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _signupFormKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();

  // Removed state variables for typed values, use controllers directly

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    final String typedEmail = _emailController.text.trim();
    final String typedPassword = _passwordController.text;
    final String typedUsername = _usernameController.text.trim();
    final String typedFullname = _fullnameController.text.trim();

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: typedEmail,
        password: typedPassword,
      );
      User? user = credential.user;

      if (user != null) {
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.set({
          'username': typedUsername,
          'fullname': typedFullname, // Corrected key to 'fullname'
          'email': typedEmail,
          'createdAt': FieldValue.serverTimestamp(),
          'points': 0,
          'gallery': [], // Initialize gallery as empty list
          'favoritePlantIds': [], // Initialize favorites as empty list
          // Add other fields like dateOfBirth, address if needed initially
          'dateOfBirth': null,
          'address': '',
        });
        // Optionally update Firebase Auth profile
        // await user.updateDisplayName(typedFullname);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // --- Hardcoded English Success Message ---
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      // --- Error messages remain hardcoded English ---
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak (min 6 characters).';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Unable to register. Please try again.';
      }
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message), // Hardcoded error message
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print("Error during registration or Firestore save: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // --- Hardcoded English Error Message ---
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    // --- Get AppLocalizations instance ---
    final l10n = AppLocalizations.of(context)!;

    return CustomScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              const Expanded(flex: 1, child: SizedBox(height: 10)),
              Expanded(
                flex: 9, // Adjusted flex to give more space
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 40.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _signupFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Localized Text ---
                          Text(
                            l10n.signupCreateAccountTitle, // Use key
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // --- Full Name Field ---
                          TextFormField(
                            controller: _fullnameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // --- Hardcoded English Validation ---
                                return 'Please enter your Full Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              // --- Localized Text ---
                              labelText: l10n.signupFullNameLabel, // Use key
                              hintText: l10n.signupFullNameHint, // Use key
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 20.0),

                          // --- Username Field ---
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // --- Hardcoded English Validation ---
                                return 'Please enter a Username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              // --- Localized Text ---
                              labelText: l10n.signupUsernameLabel, // Use key
                              hintText: l10n.signupUsernameHint, // Use key
                              prefixIcon:
                                  const Icon(Icons.account_circle_outlined),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // --- Email Field ---
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // --- Hardcoded English Validation ---
                                return 'Please enter Email';
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                // --- Hardcoded English Validation ---
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              // --- Localized Text ---
                              labelText: l10n.signupEmailLabel, // Use key
                              hintText: l10n.signupEmailHint, // Use key
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20.0),

                          // --- Password Field ---
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // --- Hardcoded English Validation ---
                                return 'Please enter Password';
                              }
                              if (value.length < 6) {
                                // --- Hardcoded English Validation ---
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              // --- Localized Text ---
                              labelText: l10n.signupPasswordLabel, // Use key
                              hintText: l10n.signupPasswordHint, // Use key
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // --- Confirm Password Field ---
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // --- Hardcoded English Validation ---
                                return 'Please confirm your Password';
                              }
                              if (value != _passwordController.text) {
                                // --- Hardcoded English Validation ---
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              // --- Localized Text ---
                              labelText:
                                  l10n.signupConfirmPasswordLabel, // Use key
                              hintText:
                                  l10n.signupConfirmPasswordHint, // Use key
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // --- Sign Up Button ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _register,
                              // --- Localized Text ---
                              child: Text(
                                l10n.signupSignUpButton, // Use key
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25.0),

                          // --- Sign In Link ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // --- Localized Text ---
                              Text(l10n.signupHaveAccountPrompt), // Use key
                              TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                                // --- Localized Text ---
                                child: Text(l10n.signupSignInLink), // Use key
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // --- Language Popup (Keep as is, add LocaleProvider logic) ---
          Positioned(
            top: 10,
            right: 10,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.language,
                  color: Colors.white), // Icon color white
              tooltip: 'Select Language', // Hardcoded tooltip
              onSelected: (String langCode) {
                // --- Added LocaleProvider logic ---
                print('Language selected: $langCode');
                final localeProvider = Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                );
                localeProvider.setLocale(Locale(langCode));
                // --- End Added Logic ---
              },
              itemBuilder: (BuildContext context) {
                // --- Menu item text remains hardcoded English ---
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
