// test/unit/movie_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cs442_mp6/models/movie.dart';

void main() {
  group('Movie Model Tests', () {
    // Test all the required fields with complete JSON data
    test('Movie model serialization with complete data', () {
      final json = {
        'id': 1,
        'title': 'Test Movie',
        'overview': 'A test movie.',
        'poster_path': '/poster.jpg',
        'release_date': '2025-01-01',
        'vote_average': 7.5,
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 1);
      expect(movie.title, 'Test Movie');
      expect(movie.overview, 'A test movie.');
      expect(movie.posterPath, '/poster.jpg');
      expect(movie.releaseDate, '2025-01-01');
      expect(movie.rating, 7.5);
    });

    // Test fallback when title is missing
    test('Movie model handles missing title with default', () {
      final json = {
        'id': 2,
        'overview': 'Test overview',
        'release_date': '2025-01-01',
        'vote_average': 8.0,
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 2);
      expect(movie.title, 'No Title');
      expect(movie.overview, 'Test overview');
      expect(movie.releaseDate, '2025-01-01');
      expect(movie.rating, 8.0);
    });

    // Test missing rating
    test('Movie model handles missing rating with default zero', () {
      final json = {
        'id': 5,
        'title': 'Test Movie',
        'overview': 'Test overview',
        'release_date': '2025-01-01',
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 5);
      expect(movie.title, 'Test Movie');
      expect(movie.overview, 'Test overview');
      expect(movie.releaseDate, '2025-01-01');
      expect(movie.rating, 0.0); // Default to 0 when missing
    });
  });
}