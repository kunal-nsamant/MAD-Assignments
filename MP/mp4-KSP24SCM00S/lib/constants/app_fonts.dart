import 'package:flutter/material.dart';
import 'app_colors.dart';

// Fonts used across the app for a clean, unified look
class AppFonts {
  static const heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}
