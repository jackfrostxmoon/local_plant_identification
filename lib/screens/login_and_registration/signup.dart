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

  // Visibility state for each password field
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true; // Added state for confirm password

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();

  // State variables for typed values (optional, could use controllers directly)
  String _typedEmail = '';
  String _typedPassword = '';
  String _typedUsername = '';
  String _typedFullname = '';

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

    _typedEmail = _emailController.text.trim();
    _typedPassword = _passwordController.text; // No trim for password
    _typedUsername = _usernameController.text.trim();
    _typedFullname = _fullnameController.text.trim();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _typedEmail,
            password: _typedPassword,
          );
      User? user = credential.user;

      if (user != null) {
        DocumentReference userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await userDoc.set({
          'username': _typedUsername,
          'fullname': _typedFullname,
          'email': _typedEmail,
          'createdAt': FieldValue.serverTimestamp(),
          'points': 0,
        });
        // Optionally update Firebase Auth profile
        // await user.updateDisplayName(_typedFullname);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Unable to register. Please try again.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak (min 6 characters).';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
    return CustomScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              const Expanded(flex: 1, child: SizedBox(height: 10)),
              Expanded(
                flex: 9,
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
                          Text(
                            'Create Account',
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
                                return 'Please enter your Full Name';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 20.0),

                          // --- Username Field ---
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a Username';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // --- Email Field ---
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20.0),

                          // --- Password Field ---
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword, // Use state variable
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Toggle icon based on state
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  // Toggle the state for this field
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
                            obscureText:
                                _obscureConfirmPassword, // Use its own state variable
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your Password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              // Add InputDecoration here too
                              labelText: 'Confirm Password',
                              hintText: 'Enter your password again',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                // Add the toggle icon
                                icon: Icon(
                                  // Toggle icon based on confirm password state
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  // Toggle the state for *this* field
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
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
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
                              const Text('Already have an account?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                                child: const Text('Sign In'),
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
          // --- Language Popup (Keep as is) ---
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
