import 'package:flutter/material.dart';
import '../../config/theme/spacing_tokens.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? hint;

  const AppTextField({super.key, required this.controller, required this.label, this.keyboardType = TextInputType.text, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }
}
