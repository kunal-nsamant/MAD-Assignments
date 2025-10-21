import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/pagination_widget.dart';
import 'favorites_screen.dart';
import 'movie_detail_screen.dart';

// Main home screen, this is where users see the list of movies
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // need to wait for the widget tree to build before accessing Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      await provider.loadFavorites(); // Load saved favorites first
      provider.loadMovies(page: 1); // then load movies from API
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovieProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        // responsive app bar design
        title: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 600;
            
            if (isSmallScreen) {
              return Row(
                children: [
                  // MovieMate logo with yellow background
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C518), // IMDb yellow
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'MovieMate',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // full layout for desktop
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C518),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'MovieMate',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
        actions: [
          // Toggle between popular and top_rated movies
          IconButton(
            icon: Icon(
              provider.category == 'popular' 
                ? Icons.toggle_off_outlined 
                : Icons.toggle_on_outlined,
              size: 28,
            ),
            onPressed: provider.isLoading ? null : () => provider.toggleCategory(),
            tooltip: 'Toggle Category: ${provider.category == 'popular' ? 'Switch to Top Rated' : 'Switch to Popular'}',
          ),
          // Navigate to favorites screen
          IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
            tooltip: 'View Favorites',
          ),
        ],
      ),
      body: Column(
        children: [
          // Main movies list area
          Expanded(
            child: provider.movies.isEmpty && provider.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading movies...'),
                      ],
                    ),
                  )
                : provider.movies.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No movies found', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          // Responsive layout
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 800) {
                                return GridView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: constraints.maxWidth * 0.05,
                                    vertical: 16,
                                  ),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: provider.movies.length,
                                  itemBuilder: (context, index) {
                                    final movie = provider.movies[index];
                                    final serialNumber = (provider.currentPage - 1) * 20 + (index + 1);
                                    return MovieCard(
                                      movie: movie,
                                      serialNumber: serialNumber,
                                      isGridView: true,
                                      onTap: () async {
                                        // Show loading dialog while fetching details
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator()
                                          ),
                                        );
                                        final detailedMovie = await provider.fetchMovieById(movie.id);
                                        Navigator.of(context).pop(); // Remove loading dialog
                                        if (detailedMovie != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MovieDetailScreen(movie: detailedMovie),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Failed to load movie details.')),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              } else {
                                // Use ListView for narrow screens
                                return ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: constraints.maxWidth * 0.02,
                                    vertical: 16,
                                  ),
                                  itemCount: provider.movies.length,
                                  itemBuilder: (context, index) {
                                    final movie = provider.movies[index];
                                    final serialNumber = (provider.currentPage - 1) * 20 + (index + 1);
                                    return MovieCard(
                                      movie: movie,
                                      serialNumber: serialNumber,
                                      isGridView: false,
                                      onTap: () async {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator()
                                          ),
                                        );
                                        final detailedMovie = await provider.fetchMovieById(movie.id);
                                        Navigator.of(context).pop();
                                        if (detailedMovie != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MovieDetailScreen(movie: detailedMovie),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Failed to load movie details.')),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),
                          // Loading overlay
                          if (provider.isLoading)
                            Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.white),
                                    SizedBox(height: 16),
                                    Text(
                                      'Loading movies...',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
          
          // Pagination controls
          if (provider.totalPages > 1)
            PaginationWidget(
              currentPage: provider.currentPage,
              totalPages: provider.totalPages,
              isLoading: provider.isLoading,
              onPrevious: provider.previousPage,
              onNext: provider.nextPage,
              onPageSelect: provider.goToPage,
            ),
        ],
      ),
    );
  }
}
