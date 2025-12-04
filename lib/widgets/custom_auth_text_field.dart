// lib/widgets/custom_auth_text_field.dart
import 'package:flutter/material.dart';

class CustomAuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool? isPassword;

  const CustomAuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.labelText,
    this.keyboardType,
    this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ?? false,
      keyboardType: keyboardType ?? TextInputType.text,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 17),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // borderSide: BorderSide.none,
        ),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(12),
        //   borderSide: BorderSide.none,
        // ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter the value";
        }
        return null;
      },
    );
  }
}
