import 'package:flutter/material.dart';

extension SnakBarExtension on BuildContext {
  void showSnackBar({required String message, Color color = Colors.green}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
      ),
    );
  }
}
