// test/integration/app_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cs442_mp6/models/movie.dart';
import 'package:cs442_mp6/providers/movie_provider.dart';
import 'package:cs442_mp6/screens/home_screen.dart';
import 'package:cs442_mp6/screens/favorites_screen.dart';


// Mock provider to avoid making real API calls during testing
class MockMovieProvider extends MovieProvider {
  @override
  Future<void> loadMovies({int page = 1}) async {
    // Simulate API loading without actual network call
    isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 100)); // Fake network delay
    
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> toggleCategory() async {
    category = category == 'popular' ? 'top_rated' : 'popular';
    notifyListeners();
    // Skip the real API call
  }

  @override
  Future<void> previousPage() async {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  @override
  Future<void> nextPage() async {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }

  @override
  Future<Movie?> fetchMovieById(int id) async {
    // Return mock movie instead of API call
    return movies.firstWhere((movie) => movie.id == id);
  }
}

void main() {
  group('MovieMate App Integration Tests', () {
    // Test data
    final testMovies = [
      Movie(
        id: 1,
        title: 'Test Movie 1',
        overview: 'This is a test movie for integration testing.',
        posterPath: null,
        releaseDate: '2024-01-01',
        rating: 8.5,
      ),
      Movie(
        id: 2,
        title: 'Test Movie 2',
        overview: 'This is another test movie.',
        posterPath: null,
        releaseDate: '2024-01-02',
        rating: 7.8,
      ),
    ];

    late MockMovieProvider movieProvider;

    setUp(() {
      movieProvider = MockMovieProvider();
      // Set up mock data for each test
      movieProvider.movies = testMovies;
      movieProvider.isLoading = false;
      movieProvider.currentPage = 1;
      movieProvider.totalPages = 1;
      movieProvider.totalResults = 2;
      movieProvider.category = 'popular';
    });

    // Helper to create test app with provider
    Widget createTestApp({Widget? home, Map<String, WidgetBuilder>? routes}) {
      return ChangeNotifierProvider<MovieProvider>.value(
        value: movieProvider,
        child: MaterialApp(
          home: home ?? const HomeScreen(),
          routes: routes ?? {},
          navigatorKey: GlobalKey<NavigatorState>(),
        ),
      );
    }

    // Test basic app functionality - it display movies?
    testWidgets('Home screen displays movies correctly', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Check test movies appear on screen
      expect(find.text('Test Movie 1'), findsOneWidget);
      expect(find.text('Test Movie 2'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsWidgets);
      
      // Should not show pagination with only 1 page
      expect(find.text('Previous'), findsNothing);
      expect(find.text('Next'), findsNothing);
    });

    // Test the core favorites functionality
    testWidgets('Can favorite and unfavorite movies', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find heart button and favorite a movie
      final heartButtons = find.byIcon(Icons.favorite_border);
      expect(heartButtons, findsWidgets);
      
      await tester.tap(heartButtons.first);
      await tester.pumpAndSettle();

      // Heart should change to filled
      expect(find.byIcon(Icons.favorite), findsWidgets);
      
      // Wait for snackbar to disappear
      await tester.pump(const Duration(seconds: 2));
      
      // Unfavorite by tapping filled heart
      final movieHearts = find.byIcon(Icons.favorite);
      await tester.tap(movieHearts.first);
      await tester.pumpAndSettle();

      // Should go back to unfavorited state
      expect(find.byIcon(Icons.favorite_border), findsWidgets);
    });

    // Test navigation to favorites screen
    testWidgets('Can navigate to favorites screen', (tester) async {
      await tester.pumpWidget(createTestApp(
        routes: {
          '/favorites': (context) => const FavoritesScreen(),
        },
      ));
      await tester.pumpAndSettle();

      // favorite a movie so we have something to see
      final heartButtons = find.byIcon(Icons.favorite_border);
      await tester.tap(heartButtons.first);
      await tester.pumpAndSettle();

      // Wait for snackbar to disappear
      await tester.pump(const Duration(seconds: 2));

      // Tap the favorites button in app bar
      final appBarHeart = find.byIcon(Icons.favorite).last;
      await tester.tap(appBarHeart);
      await tester.pumpAndSettle();

      // Should be on favorites screen now
      expect(find.text('Favorites (1)'), findsOneWidget);
      expect(find.text('Test Movie 1'), findsOneWidget);
    });

    // Test category toggle functionality
    testWidgets('Category switching works', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should start with popular
      expect(find.text('POPULAR'), findsOneWidget);
      
      // Find and tap toggle button
      final toggleButton = find.byIcon(Icons.toggle_off_outlined);
      expect(toggleButton, findsOneWidget);
      
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Should switch to top rated
      expect(find.text('TOP_RATED'), findsOneWidget);
      
      // Toggle icon should change
      expect(find.byIcon(Icons.toggle_on_outlined), findsOneWidget);
    });
  });
}
