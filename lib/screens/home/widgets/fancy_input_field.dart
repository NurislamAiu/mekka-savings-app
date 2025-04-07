import 'package:flutter/material.dart';

class FancyInputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;

  const FancyInputField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal.shade100),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}