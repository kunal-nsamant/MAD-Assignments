import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

// Favorites screen
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovieProvider>(context);
    final favs = provider.sortedFavoriteMovies; // get sorted list based on user preference

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites (${favs.length})'), // show count in title
        actions: [
          // only show sort button if there are favorites to sort
          if (favs.isNotEmpty)
            IconButton(
              onPressed: () => provider.toggleFavoritesSorting(),
              icon: Icon(
                provider.sortFavoritesAlphabetically 
                    ? Icons.sort_by_alpha 
                    : Icons.access_time,
              ),
              tooltip: provider.sortFavoritesAlphabetically 
                  ? 'Sort by Date Added' 
                  : 'Sort Alphabetically',
            ),
        ],
      ),
      body: favs.isEmpty
          ? const Center(
              // empty state
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the ♥ button on movies to add them here',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          // list view for favorites
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: favs.length,
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: favs[index],
                  serialNumber: index + 1,
                  onTap: () async {
                    // Same loading pattern as home screen
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator()
                      ),
                    );
                    final detailedMovie = await provider.fetchMovieById(favs[index].id);
                    Navigator.of(context).pop(); // Remove loading dialog
                    if (detailedMovie != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie: detailedMovie),
                        ),
                      );
                    } else {
                      // Show error if API call fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to load movie details.')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
