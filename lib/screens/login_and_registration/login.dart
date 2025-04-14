import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart'; // Assuming this exists
import 'package:local_plant_identification/screens/login_and_registration/forgetpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_plant_identification/widgets/custom_text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _loginFormKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  // No need for _obscurePassword here anymore
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // No need for _typedEmail and _typedPassword here, get from controllers directly

  @override
  void initState() {
    super.initState();
    // Consider initializing Firebase in main.dart for better practice
    // _initializeFirebase();
  }

  // Removed _initializeFirebase as it's better done once in main.dart

  Future<void> _login() async {
    // Get values directly from controllers
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Ensure the form is valid before proceeding
    if (!_loginFormKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        // Use pushReplacementNamed to prevent going back to login
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // 'invalid-credential' is a more common code now
        errorMessage = 'Wrong email or password provided.';
      } else {
        errorMessage = 'An error occurred during login. Please try again.';
        print('Firebase Auth Error: ${e.code} - ${e.message}'); // Log details
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent, // Slightly different red
            content: Text(errorMessage),
            duration: const Duration(seconds: 4), // Slightly longer
          ),
        );
      }
    } catch (e) {
      // Catch generic errors
      print('Generic Login Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('An unexpected error occurred. Please try again.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    return CustomScaffold(
      // Make sure CustomScaffold is defined correctly
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
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          // Use the CustomTextField for Email
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Enter Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              // Basic email format validation (optional but recommended)
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          // Use the CustomTextField for Password
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Enter Password',
                            isPassword: true, // Set this to true
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              // Optional: Add password length validation
                              // if (value.length < 6) {
                              //   return 'Password must be at least 6 characters';
                              // }
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
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const ForgetPassword(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forget password?',
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
                              // Use the _login method directly here
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
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Removed redundant SizedBoxes and Row
                          const SizedBox(height: 30.0), // Adjusted spacing
                          // don't have an account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account? ',
                                style: TextStyle(color: Colors.black45),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Consider pushReplacement if you don't want users
                                  // to navigate back from Signup to Login easily
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const Signup(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign up',
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
              icon: Icon(Icons.language, color: lightColorScheme.primary),
              onSelected: (String value) {
                // Handle language change logic here
                print('Language selected: $value');
              },
              itemBuilder: (BuildContext context) {
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
