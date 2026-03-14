import 'package:flutter/material.dart';

Widget customText({
  required String textHint,
  required String textLabel,
  required TextEditingController? controller,
  required TextInputType keyboardType,
  bool obsecureText = false,
  String? Function(String?)? validator,
  required Icon prefixIcon,
  IconButton? suffixIcon,
}) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: TextFormField(
      obscureText: obsecureText,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        suffixIcon: textLabel == 'Password' ? suffixIcon : null,
        prefixIcon: prefixIcon,
        hint: Text(textHint),
        labelText: textLabel,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
