import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';

// Movie card widget - displays individual movie info in lists and grids
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final int serialNumber; // For pagination numbering
  final bool isGridView; // Different layout for grid vs list

  const MovieCard({
    Key? key,
    required this.movie,
    required this.onTap,
    required this.serialNumber,
    this.isGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = constraints.maxWidth;
        
        // Responsive sizing
        final posterWidth = isGridView ? cardWidth * 0.25 : 80.0;
        final posterHeight = isGridView ? posterWidth * 1.5 : 120.0;
        final padding = screenWidth < 600 ? 8.0 : 12.0;
        final margin = screenWidth < 600 
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        
        return Card(
          elevation: 4,
          margin: margin,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // shows position in current page
                  Container(
                    width: _getSerialNumberWidth(serialNumber),
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C518).withOpacity(0.1), // Light yellow background
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF5C518).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          '$serialNumber',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF5C518), // Yellow text
                            fontSize: _getSerialNumberFontSize(serialNumber),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Movie poster image
                  Container(
                    width: posterWidth,
                    height: posterHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: movie.posterPath?.isNotEmpty == true
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w300${movie.posterPath}', // TMDB poster URL
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Show movie icon if image fails to load
                                return const Icon(
                                  Icons.movie,
                                  size: 40,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.movie,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Movie info section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie title
                        Text(
                          movie.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Rating with star and colored badge
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Color coded rating badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRatingColor(movie.rating),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getRatingLabel(movie.rating),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Release date with calendar icon
                        if (movie.releaseDate?.isNotEmpty == true)
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(movie.releaseDate!),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Heart button for favorites
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
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                provider.addMovieToFavorites(movie);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${movie.title} added to favorites'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                      ),
                      
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) return Colors.green;
    if (rating >= 6.0) return Colors.orange;
    return Colors.red;
  }

  String _getRatingLabel(double rating) {
    if (rating >= 8.0) return 'Great';
    if (rating >= 6.0) return 'Good';
    return 'Poor';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  double _getSerialNumberWidth(int number) {
    final digits = number.toString().length;
    if (digits <= 2) return 45.0;
    if (digits == 3) return 55.0;  
    if (digits == 4) return 65.0;
    return 75.0;
  }

  double _getSerialNumberFontSize(int number) {
    final digits = number.toString().length;
    if (digits <= 2) return 18.0;
    if (digits == 3) return 16.0;
    if (digits == 4) return 14.0;
    return 12.0;
  }
}
