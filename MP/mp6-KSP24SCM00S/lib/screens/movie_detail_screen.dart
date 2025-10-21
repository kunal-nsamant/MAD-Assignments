import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';

// Detail screen for individual movies
class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          // heart button to add or remove from favorites
          Consumer<MovieProvider>(
            builder: (context, provider, child) {
              final isFavorite = provider.favoriteIds.contains(movie.id);
              return IconButton(
                onPressed: () {
                  if (isFavorite) {
                    provider.removeFavorite(movie.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${movie.title} removed from favorites'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    provider.addMovieToFavorites(movie); // Add full movie object
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${movie.title} added to favorites'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null, // Red when favorited
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // movie poster
            if (movie.posterPath?.isNotEmpty == true)
              Center(
                child: Image.network(
                  'https://image.tmdb.org/t/p/w300${movie.posterPath}', // TMDB image URL
                  height: 400,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Release Date: ${movie.releaseDate}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Rating: ${movie.rating.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Movie overview or description
            Text(movie.overview),
          ],
        ),
      ),
    );
  }
}
