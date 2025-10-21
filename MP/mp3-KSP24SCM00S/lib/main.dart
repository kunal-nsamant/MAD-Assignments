// main.dart
import 'package:flutter/material.dart';
import 'views/welcome_screen.dart';

// entry point of the app
void main() {
  runApp(const YahtzeeApp());
}

// root widget of the application
class YahtzeeApp extends StatelessWidget {
  const YahtzeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yahtzee', // App title shown in system UI
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red[800],
        scaffoldBackgroundColor: Colors.grey[300], // background color for all screens
        fontFamily: 'Georgia', // default font

        // Define color scheme for the app
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.red[800],
          secondary: Colors.yellow[700],
        ),

        // Define text styles
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontFamily: 'Georgia',
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontFamily: 'Courier',
            color: Colors.black87,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        // styling for elevated buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800], // Button background
            foregroundColor: Colors.white, // Button text color
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),

        // Styling for progress indicators, loading bars
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.yellow[700],
        ),
      ),
      home: const WelcomeScreen(), // first screen the user sees
    );
  }
}
