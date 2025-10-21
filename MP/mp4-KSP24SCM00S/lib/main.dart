import 'package:flutter/material.dart';
import 'views/deck_list_screen.dart';
import 'constants/app_colors.dart';
import 'constants/app_fonts.dart';

// Main function that launches the app
void main() {
  runApp(const FlashcardApp());
}

// Root widget of the app
class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      debugShowCheckedModeBanner: false,

      // Custom theme for consistent colors and fonts
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 4,
          titleTextStyle: AppFonts.heading,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: AppFonts.body,
          titleLarge: AppFonts.heading,
        ),
      ),

      // Starting screen of the app, deck list
      home: const DeckListScreen(),
    );
  }
}
