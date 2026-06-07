import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconForLabel(label);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  IconData _iconForLabel(String label) {
    final normalized = label.toLowerCase();

    if (normalized.contains('email')) {
      return Icons.alternate_email_rounded;
    }

    if (normalized.contains('password')) {
      return Icons.lock_rounded;
    }

    if (normalized.contains('name')) {
      return Icons.person_rounded;
    }

    return Icons.edit_rounded;
  }
}