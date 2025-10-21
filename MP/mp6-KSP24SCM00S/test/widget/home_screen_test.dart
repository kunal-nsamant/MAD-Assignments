// test/widget/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs442_mp6/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:cs442_mp6/providers/movie_provider.dart';
import 'package:cs442_mp6/models/movie.dart';

void main() {
  group('Home Screen Widget Tests', () {
    late MovieProvider mockProvider;

    setUp(() {
      mockProvider = MovieProvider();
    });

    // Test loading state
    testWidgets('Home screen shows loading initially', (tester) async {
      // Set provider to loading state
      mockProvider.isLoading = true;
      mockProvider.movies = [];
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      
      // Should show loading spinner and message
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading movies...'), findsOneWidget);
    });

    // Test normal state with movies loaded
    testWidgets('Home screen shows movie list when loaded', (tester) async {
      // Create test movie data
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.5,
      );
      
      // Set up provider with loaded state
      mockProvider.movies = [testMovie];
      mockProvider.currentPage = 1;
      mockProvider.totalPages = 10;
      mockProvider.totalResults = 200;
      mockProvider.isLoading = false;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pump();

      // Should display the movie and list view
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    // Test pagination controls appear when needed
    testWidgets('Home screen shows pagination when multiple pages', (tester) async {
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.5,
      );
      
      // Set up multi-page scenario
      mockProvider.movies = [testMovie];
      mockProvider.currentPage = 1;
      mockProvider.totalPages = 5; // Multiple pages
      mockProvider.isLoading = false;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pump();

      // Should show pagination controls
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Page 1 of 5'), findsOneWidget);
    });
  });
}
