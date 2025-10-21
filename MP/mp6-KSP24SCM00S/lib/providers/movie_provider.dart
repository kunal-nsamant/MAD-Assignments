import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

// Main state management class handles everything related to movies
// using ChangeNotifier so the UI updates automatically when data changes
class MovieProvider extends ChangeNotifier {
  List<Movie> movies = [];
  String category = 'popular'; // Start with popular movies
  
  // Favorites management
  Set<int> favoriteIds = {};
  List<Movie> favoriteMovies = []; // store actual movie objects for display
  Map<int, DateTime> favoriteTimestamps = {}; // Track when movies were favorited
  bool sortFavoritesAlphabetically = false; // user preference for sorting
  
  // Pagination state, TMDB gives us 20 movies per page
  int currentPage = 1;
  int totalPages = 1;
  int totalResults = 0;
  bool isLoading = false; // for showing loading spinners

  // Main method to fetch movies from API
  Future<void> loadMovies({int page = 1}) async {
    final validPage = page.clamp(1, 500).toInt();
    
    isLoading = true;
    notifyListeners();
    
    print('MovieProvider: Calling ApiService.fetchMovies with category: $category, page: $validPage');
    try {
      final response = await ApiService.fetchMovies(category, page: validPage);
      movies = response.movies;
      currentPage = response.currentPage;
      totalPages = response.totalPages;
      totalResults = response.totalResults;
      
      print('MovieProvider: Movies loaded, count: ${movies.length}, page: $currentPage/$totalPages');
    } catch (e) {
      print('MovieProvider: Error loading movies: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // update UI regardless of success orfailure
    }
  }

  // Navigation methods for pagination
  Future<void> nextPage() async {
    if (currentPage < totalPages && !isLoading) {
      await loadMovies(page: currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (currentPage > 1 && !isLoading) {
      await loadMovies(page: currentPage - 1);
    }
  }

  //jump to specific page
  Future<void> goToPage(int page) async {
    final maxPage = totalPages > 500 ? 500 : totalPages; // API limitation
    final validPage = page.clamp(1, maxPage).toInt();
    if (validPage != currentPage && !isLoading) {
      await loadMovies(page: validPage);
    }
  }

  // Switch between popular and top_rated categories
  void toggleCategory() {
    category = category == 'popular' ? 'top_rated' : 'popular';
    currentPage = 1; // always reset to first page when switching
    loadMovies(page: 1);
  }

  // Get detailed movie info for detail screen
  Future<Movie?> fetchMovieById(int id) async {
    try {
      return await ApiService.fetchMovieById(id);
    } catch (e) {
      print('Error fetching movie by ID: $e');
      return null; // Return null so UI can handle
    }
  }

  // keys for SharedPreferences storage
  static const String _favoriteIdsKey = 'favorite_ids';
  static const String _favoriteMoviesKey = 'favorite_movies';
  static const String _favoriteTimestampsKey = 'favorite_timestamps';
  static const String _sortPreferenceKey = 'sort_preference';

  // Load saved favorites when app starts
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load favorite ID's
      final favoriteIdStrings = prefs.getStringList(_favoriteIdsKey) ?? [];
      favoriteIds = favoriteIdStrings.map((id) => int.parse(id)).toSet();
      
      // Load full movie objects
      final favoriteMoviesJson = prefs.getStringList(_favoriteMoviesKey) ?? [];
      favoriteMovies = favoriteMoviesJson.map((movieJson) {
        final Map<String, dynamic> json = jsonDecode(movieJson);
        return Movie.fromJson(json);
      }).toList();
      
      // Load timestamps for date wise sorting
      final timestampsJson = prefs.getString(_favoriteTimestampsKey);
      if (timestampsJson != null) {
        final Map<String, dynamic> timestampsMap = jsonDecode(timestampsJson);
        favoriteTimestamps = timestampsMap.map((key, value) => 
          MapEntry(int.parse(key), DateTime.parse(value))
        );
      }
      
      // Load user's sorting preference
      sortFavoritesAlphabetically = prefs.getBool(_sortPreferenceKey) ?? false;
      
      print('📱 Loaded ${favoriteMovies.length} favorites from storage');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading favorites: $e');
    }
  }

  // Save favorites to device storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save as string list
      final favoriteIdStrings = favoriteIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_favoriteIdsKey, favoriteIdStrings);
      
      // save full movie data as JSON strings
      final favoriteMoviesJson = favoriteMovies.map((movie) {
        return jsonEncode({
          'id': movie.id,
          'title': movie.title,
          'overview': movie.overview,
          'poster_path': movie.posterPath,
          'release_date': movie.releaseDate,
          'vote_average': movie.rating,
        });
      }).toList();
      await prefs.setStringList(_favoriteMoviesKey, favoriteMoviesJson);
      
      // Save timestamps as JSON
      final timestampsMap = favoriteTimestamps.map((key, value) => 
        MapEntry(key.toString(), value.toIso8601String())
      );
      await prefs.setString(_favoriteTimestampsKey, jsonEncode(timestampsMap));
      
      // Save sort preference
      await prefs.setBool(_sortPreferenceKey, sortFavoritesAlphabetically);
      
      print('💾 Saved ${favoriteMovies.length} favorites to storage');
    } catch (e) {
      print('❌ Error saving favorites: $e');
    }
  }

  void addFavorite(int movieId) {
    favoriteIds.add(movieId);
    // try to find the movie in current list
    final movie = movies.firstWhere((m) => m.id == movieId, orElse: () => Movie(
      id: movieId,
      title: 'Unknown Movie',
      posterPath: null,
      overview: 'No overview available',
      releaseDate: 'Unknown',
      rating: 0.0,
    ));
    if (!favoriteMovies.any((m) => m.id == movieId)) {
      favoriteMovies.add(movie);
      favoriteTimestamps[movieId] = DateTime.now(); // Remember when user favorited it
    }
    _saveFavorites(); // Auto save after every change
    notifyListeners();
  }

  void removeFavorite(int movieId) {
    favoriteIds.remove(movieId);
    favoriteMovies.removeWhere((movie) => movie.id == movieId);
    favoriteTimestamps.remove(movieId);
    _saveFavorites();
    notifyListeners();
  }

  void addMovieToFavorites(Movie movie) {
    favoriteIds.add(movie.id);
    if (!favoriteMovies.any((m) => m.id == movie.id)) {
      favoriteMovies.add(movie);
      favoriteTimestamps[movie.id] = DateTime.now();
    }
    _saveFavorites();
    notifyListeners();
  }

  // Toggle between alphabetical and date added sorting
  void toggleFavoritesSorting() {
    sortFavoritesAlphabetically = !sortFavoritesAlphabetically;
    _saveFavorites(); // Remember user's preference
    notifyListeners();
  }

  // Get sorted favorite movies based on user preference
  List<Movie> get sortedFavoriteMovies {
    if (sortFavoritesAlphabetically) {
      // A to Z sorting
      return List.from(favoriteMovies)..sort((a, b) => a.title.compareTo(b.title));
    } else {
      // Date added sorting
      return List.from(favoriteMovies)..sort((a, b) {
        final timestampA = favoriteTimestamps[a.id] ?? DateTime.now();
        final timestampB = favoriteTimestamps[b.id] ?? DateTime.now();
        return timestampA.compareTo(timestampB);
      });
    }
  }

  // clear all favorites
  Future<void> clearAllFavorites() async {
    favoriteIds.clear();
    favoriteMovies.clear();
    favoriteTimestamps.clear();
    await _saveFavorites();
    notifyListeners();
    print('🗑️ Cleared all favorites');
  }
}
