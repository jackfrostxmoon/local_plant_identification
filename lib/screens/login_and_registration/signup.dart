import 'package:flutter/material.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _signupFormKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  String _typedEmail = '';
  String _typedPassword = '';
  String _typedUsername = '';
  String _typedFullname = '';

  Future<void> _register() async {
    _typedEmail = _emailController.text;
    _typedPassword = _passwordController.text;
    _typedUsername = _usernameController.text;
    _typedFullname = _fullnameController.text;
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _typedEmail,
        password: _typedPassword,
      );
      User? user = credential.user;
      if (user != null) {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        userDoc.set({
          'username': _typedUsername,
          'fullname': _typedFullname,
        });
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (_) {
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: const Text('Unable to register'),
        duration: const Duration(seconds: 3),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    return CustomScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              const Expanded(
                flex: 1,
                child: SizedBox(
                  height: 10,
                ),
              ),
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
                      key: _signupFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(
                            height: 40.0,
                          ),
                          TextFormField(
                            controller: _emailController, // Add controller
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _passwordController, // Add controller
                            obscureText: _obscurePassword,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _confirmPasswordController, // Add controller
                            obscureText: _obscurePassword,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Confirm Password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Enter your password again',
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Set the button color to green
                            ),
                            onPressed: () {
                              if (_signupFormKey.currentState!.validate()) {
                                _register(); // Call the register method
                              }
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white, // Set the text color to white
                                fontWeight: FontWeight.bold, // Make the text bold
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
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