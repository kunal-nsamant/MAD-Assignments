import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs442_mp6/widgets/movie_card.dart';
import 'package:cs442_mp6/models/movie.dart';
import 'package:provider/provider.dart';
import 'package:cs442_mp6/providers/movie_provider.dart';

void main() {
  group('Movie Card Widget Tests', () {
    late MovieProvider mockProvider;
    late Movie testMovie;

    setUp(() {
      mockProvider = MovieProvider();
      // Standard test movie data used across multiple tests
      testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.5,
      );
    });

    // Test basic movie info display
    testWidgets('Movie card displays movie information correctly', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: MovieCard(
                movie: testMovie,
                serialNumber: 1,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Check all the key info elements are visible
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget); // Rating number
      expect(find.text('2025'), findsOneWidget); // Year from release date
      expect(find.text('1'), findsOneWidget); // Serial number
      expect(find.byIcon(Icons.star), findsOneWidget); // Star rating icon
    });

    // Test favorited state display
    testWidgets('Movie card shows favorited heart when movie is favorited', (tester) async {
      // Pre favorite the movie
      mockProvider.addMovieToFavorites(testMovie);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: MovieCard(
                movie: testMovie,
                serialNumber: 1,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Should show filled heart when favorited
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });
} 