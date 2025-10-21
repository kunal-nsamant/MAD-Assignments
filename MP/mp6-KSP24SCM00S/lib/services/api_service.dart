import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../tmdb_api_key.dart';

// API service class to handle all TMDB API calls
class ApiService {
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // main method to fetch movies
  static Future<MovieResponse> fetchMovies(String category, {int page = 1}) async {
    final url = Uri.parse(
      '$baseUrl/movie/$category?page=$page',
    );

    print('🔄 Fetching movies from: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': TMDB_API_KEY, // bearer token format required by TMDB
        'accept': 'application/json',
      },
    );

    print('📡 Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Successfully fetched: ${data['results'].length} movies for page $page');
      
      // Convert JSON array to List of Movie objects
      final movies = (data['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
      
      final apiTotalPages = data['total_pages'] ?? 1;
      final actualTotalPages = apiTotalPages > 500 ? 500 : apiTotalPages;
      
      return MovieResponse(
        movies: movies,
        currentPage: data['page'] ?? 1,
        totalPages: actualTotalPages,
        totalResults: data['total_results'] ?? 0,
      );
    } else {
      print('❌ Failed to fetch movies. Response: ${response.body}');
      throw Exception('Failed to load movies');
    }
  }

  // Get detailed info for a specific movie
  static Future<Movie> fetchMovieById(int id) async {
    final url = Uri.parse('$baseUrl/movie/$id');
    print('🔄 Fetching movie details from: $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': TMDB_API_KEY,
        'accept': 'application/json',
      },
    );
    print('📡 Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Successfully fetched movie details');
      return Movie.fromJson(data);
    } else {
      print('❌ Failed to fetch movie details. Response: ${response.body}');
      throw Exception('Failed to load movie details');
    }
  }
}

// Helper class to wrap the API response with pagination info
class MovieResponse {
  final List<Movie> movies;
  final int currentPage;
  final int totalPages;
  final int totalResults;

  MovieResponse({
    required this.movies,
    required this.currentPage,
    required this.totalPages,
    required this.totalResults,
  });
}
