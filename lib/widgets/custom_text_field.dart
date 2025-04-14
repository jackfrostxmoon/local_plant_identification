import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator,
    this.isPassword = false, // Default to false
    this.keyboardType = TextInputType.text, // Default keyboard type
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText; // Use late for initialization in initState

  @override
  void initState() {
    super.initState();
    // Initialize _obscureText based on the isPassword property
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText, // Use the state variable
      obscuringCharacter: '*',
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        label: Text(widget.labelText),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.black26),
        // Conditionally add the suffix icon only if it's a password field
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    // Toggle icon based on the state variable
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    // Toggle the obscureText state
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null, // No suffix icon if not a password field
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black12, // Default border color
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black12, // Default border color
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
