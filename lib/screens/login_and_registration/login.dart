// screens/login_and_registration/login.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:local_plant_identification/screens/login_and_registration/forgetpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_plant_identification/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:local_plant_identification/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _loginFormKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      // --- Error messages remain hardcoded English ---
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Wrong email or password provided.';
      } else {
        errorMessage = 'An error occurred during login. Please try again.';
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(errorMessage), // Hardcoded error message
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Generic Login Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            // --- Hardcoded English error message ---
            content: Text('An unexpected error occurred. Please try again.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Localized Text ---
                          Text(
                            l10n.loginWelcomeBack, // Use key
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          CustomTextField(
                            controller: _emailController,
                            // --- Localized Text ---
                            labelText: l10n.loginEmailLabel, // Use key
                            hintText: l10n.loginEmailHint, // Use key
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // --- Hardcoded English Validation Message ---
                                return 'Please enter Email';
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                // --- Hardcoded English Validation Message ---
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          CustomTextField(
                            controller: _passwordController,
                            // --- Localized Text ---
                            labelText: l10n.loginPasswordLabel, // Use key
                            hintText: l10n.loginPasswordHint, // Use key
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // --- Hardcoded English Validation Message ---
                                return 'Please enter Password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberPassword,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        rememberPassword = value!;
                                      });
                                    },
                                    activeColor: lightColorScheme.primary,
                                  ),
                                  // --- Localized Text ---
                                  Text(
                                    l10n.loginRememberMe, // Use key
                                    style:
                                        const TextStyle(color: Colors.black45),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPassword(),
                                    ),
                                  );
                                },
                                child: Text(
                                  // --- Localized Text ---
                                  l10n.loginForgotPassword, // Use key
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 100,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              // --- Localized Text ---
                              child: Text(
                                l10n.loginSignInButton, // Use key
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // --- Localized Text ---
                              Text(
                                l10n.loginNoAccountPrompt, // Use key
                                style: const TextStyle(color: Colors.black45),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const Signup(),
                                    ),
                                  );
                                },
                                child: Text(
                                  // --- Localized Text ---
                                  l10n.loginSignUpLink, // Use key
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
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
          Positioned(
            top: 10,
            right: 10,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.language, color: Colors.white),
              tooltip: 'Select Language', // Hardcoded tooltip
              onSelected: (String langCode) {
                print('Language selected: $langCode');
                final localeProvider = Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                );
                localeProvider.setLocale(Locale(langCode));
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
