import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField(
      {super.key,
      required this.labelText,
      this.obscureText = false,
      this.controller});

  final String labelText;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: Colors.indigo, fontSize: 30, height: 1.5),
      decoration: InputDecoration(labelText: labelText),
      obscureText: obscureText,
      controller: controller,
    );
  }
}
