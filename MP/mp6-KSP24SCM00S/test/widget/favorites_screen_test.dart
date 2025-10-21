// test/widget/favorites_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs442_mp6/screens/favorites_screen.dart';
import 'package:provider/provider.dart';
import 'package:cs442_mp6/providers/movie_provider.dart';
import 'package:cs442_mp6/models/movie.dart';

void main() {
  group('Favorites Screen Widget Tests', () {
    late MovieProvider mockProvider;

    setUp(() {
      mockProvider = MovieProvider();
    });

    // Test empty state - what user sees when no favorites added yet
    testWidgets('Favorites screen shows empty state when no favorites', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: const MaterialApp(home: FavoritesScreen()),
        ),
      );

      // Should show empty state message
      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.text('Tap the ♥ button on movies to add them here'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    // Test title shows count correctly
    testWidgets('Favorites screen displays movie count in title', (tester) async {
      final testMovie = Movie(
        id: 1,
        title: 'Favorite Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 9.0,
      );
      
      mockProvider.favoriteMovies = [testMovie];

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: const MaterialApp(home: FavoritesScreen()),
        ),
      );

      await tester.pump();

      // Title should show count in parentheses
      expect(find.text('Favorites (1)'), findsOneWidget);
      expect(find.text('Favorite Movie'), findsOneWidget);
    });

    // Test multiple favorites display
    testWidgets('Favorites screen shows multiple favorite movies', (tester) async {
      final movie1 = Movie(
        id: 1,
        title: 'Movie A',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.0,
      );
      
      final movie2 = Movie(
        id: 2,
        title: 'Movie B',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-02',
        rating: 7.5,
      );
      
      mockProvider.favoriteMovies = [movie1, movie2];

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: const MaterialApp(home: FavoritesScreen()),
        ),
      );

      await tester.pump();

      // Should show both movies and correct count
      expect(find.text('Favorites (2)'), findsOneWidget);
      expect(find.text('Movie A'), findsOneWidget);
      expect(find.text('Movie B'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}