import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/home_screen.dart';

// Main entry point
void main() {
  runApp(
    // Wrapping the whole app with Provider so all screens can access movie data
    ChangeNotifierProvider(
      create: (_) => MovieProvider(),
      child: const MovieMateApp(),
    ),
  );
}

class MovieMateApp extends StatelessWidget {
  const MovieMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieMate',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        primaryColor: const Color(0xFFF5C518), // IMDb yellow color
        scaffoldBackgroundColor: Colors.black, // Dark theme looks
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        // Making sure all text is white on dark background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
        // Dark cards to match the theme
        cardTheme: const CardThemeData(
          color: Color(0xFF1A1A1A),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // Remove the debug banner
    );
  }
}
