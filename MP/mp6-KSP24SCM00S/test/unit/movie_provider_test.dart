import 'package:flutter_test/flutter_test.dart';
import 'package:cs442_mp6/providers/movie_provider.dart';
import 'package:cs442_mp6/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MovieProvider Unit Tests', () {
    late MovieProvider provider;
    
    setUp(() {
      provider = MovieProvider();
      // Mock SharedPreferences to avoid file system dependencies
      SharedPreferences.setMockInitialValues({});
    });

    // Test basic favorite functionality = core feature of the app
    test('should add movie to favorites correctly', () {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.5,
      );

      provider.addMovieToFavorites(movie);

      // Check all the things that should happen when adding a favorite
      expect(provider.favoriteIds.contains(1), true);
      expect(provider.favoriteMovies.length, 1);
      expect(provider.favoriteMovies.first.title, 'Test Movie');
      expect(provider.favoriteTimestamps.containsKey(1), true); // Should track when added
    });

    // Test removing favorites
    test('should remove movie from favorites correctly', () {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.5,
      );

      // Add then remove
      provider.addMovieToFavorites(movie);
      expect(provider.favoriteIds.contains(1), true);
      
      provider.removeFavorite(1);
      // Everything should be cleaned up
      expect(provider.favoriteIds.contains(1), false);
      expect(provider.favoriteMovies.length, 0);
      expect(provider.favoriteTimestamps.containsKey(1), false);
    });

    // Edge case - prevent duplicate favorites
    test('should not add duplicate movies to favorites', () {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.5,
      );

      provider.addMovieToFavorites(movie);
      provider.addMovieToFavorites(movie); // Try to add same movie again

      // Should still only have one copy
      expect(provider.favoriteIds.length, 1);
      expect(provider.favoriteMovies.length, 1);
    });

    // Test category switching functionality
    test('should toggle category correctly', () {
      expect(provider.category, 'popular');
      
      provider.toggleCategory();
      expect(provider.category, 'top_rated');
      
      provider.toggleCategory();
      expect(provider.category, 'popular'); // Back to original
    });

    // Test alphabetical sorting
    test('should sort favorites alphabetically when enabled', () {
      final movie1 = Movie(
        id: 1,
        title: 'Zulu Movie', // Z comes last
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 8.5,
      );
      
      final movie2 = Movie(
        id: 2,
        title: 'Alpha Movie', // A comes first
        overview: 'Test overview',
        posterPath: '/test.jpg',
        releaseDate: '2025-01-01',
        rating: 7.5,
      );

      // Add in Z, A order
      provider.addMovieToFavorites(movie1);
      provider.addMovieToFavorites(movie2);
      
      // Enable alphabetical sorting
      provider.toggleFavoritesSorting();
      
      final sortedMovies = provider.sortedFavoriteMovies;
      // Should be sorted A, Z
      expect(sortedMovies.first.title, 'Alpha Movie');
      expect(sortedMovies.last.title, 'Zulu Movie');
    });
  });
} 