// Movie class to hold movie data from the API
class Movie {
  final int id;
  final String title;
  final String overview; // Movie description
  final String? posterPath;
  final String releaseDate;
  final double rating; // Vote average from TMDB

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
  });

  // Factory method to create Movie from API JSON response
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? 'No Title', // Fallback in case title is missing
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      releaseDate: json['release_date'] ?? 'Unknown',
      rating: (json['vote_average'] ?? 0).toDouble(),
    );
  }
}
