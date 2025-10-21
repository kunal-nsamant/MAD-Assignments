import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

// styles used in UI elements like cards and buttons
class AppStyles {
  // Box style for rounded cards with slight shadow
  static final roundedCard = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(2, 3),
      ),
    ],
  );

  // default elevated button style used in forms
  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 3,
    textStyle: AppFonts.button,
  );
}
