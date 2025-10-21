import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_list_notifier.dart';
import '../utils/session_manager.dart';
import '../views/login_screen.dart';
import '../views/new_game_screen.dart';
import '../views/game_board_screen.dart';
import '../views/components/game_title.dart';
import 'package:http/http.dart' as http;

// This screen shows all of the player's games (active and completed)
class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  bool _showCompleted = false; // toggle between active and completed games
  String _username = '';
  final String baseUrl = 'https://battleships-app.onrender.com';

  @override
  void initState() {
    super.initState();
    _loadUsername(); // get the username when the screen loads
  }

  // Get the username from storage
  Future<void> _loadUsername() async {
    final name = await SessionManager.getUsername();
    if (mounted) setState(() => _username = name ?? '');
  }

  // Log out the user
  Future<void> _logout() async {
    await SessionManager.clearSession();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  // Delete a game (forfeit)
  Future<void> _deleteGame(int gameId) async {
    final token = await SessionManager.getSessionToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      Provider.of<GameListNotifier>(context, listen: false).removeGame(gameId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game Forfeited')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete game: ${res.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<GameListNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 12, 12),
        title: const Text(
          'Battleships',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.fetchGames, // refresh the game list
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              color: Colors.yellow[700],
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 48, color: Colors.black),
                  const SizedBox(height: 8),
                  Text(
                    _username,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Game (Human)'),
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewGameScreen()));
                if (result == true) {
                  notifier.fetchGames();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('New Game vs Random AI'),
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewGameScreen(aiType: 'random')));
                if (result == true) {
                  await Future.delayed(const Duration(seconds: 1));
                  notifier.fetchGames();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('New Game vs Perfect AI'),
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewGameScreen(aiType: 'perfect')));
                if (result == true) {
                  await Future.delayed(const Duration(seconds: 1));
                  notifier.fetchGames();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('New Game vs One Ship AI'),
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewGameScreen(aiType: 'oneship')));
                if (result == true) {
                  await Future.delayed(const Duration(seconds: 1));
                  notifier.fetchGames();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.toggle_on),
              title: Text(_showCompleted ? 'Show Active Games' : 'Show Completed Games'),
              onTap: () {
                setState(() => _showCompleted = !_showCompleted);
                notifier.fetchGames();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: notifier.isLoading
          ? const Center(child: CircularProgressIndicator()) // show loading if needed
          : ListView(
              children: notifier.games
                  .where((g) {
                    // Only show games that belong to you
                    final isMine = g.player1 == _username || g.player2 == _username;
                    final isCompleted = g.status == 1 || g.status == 2;
                    final isActive = g.status == 0 || g.status == 3;
                    return isMine && (_showCompleted ? isCompleted : isActive);
                  })
                  .map((g) => GameTile(
                        game: g,
                        onTap: () async {
                          if (g.status == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Game still in matchmaking.')),
                            );
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GameBoardScreen(gameId: g.id)),
                            );
                            notifier.fetchGames();
                          }
                        },
                        onDelete: () => _deleteGame(g.id),
                        currentUser: _username,
                      ))
                  .toList(),
            ),
    );
  }
}
