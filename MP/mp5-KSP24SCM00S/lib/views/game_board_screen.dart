import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/session_manager.dart';
import 'components/grid_with_labels.dart';

// this screen shows the main game board where you play
class GameBoardScreen extends StatefulWidget {
  final int gameId; // which game to show

  const GameBoardScreen({super.key, required this.gameId});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  List<String> ships = [], hits = [], misses = [], wrecks = [];
  String? shotPending;
  bool isUserTurn = false;
  bool isLoading = true;
  bool gameOver = false;
  bool gameOverShown = false;

  final baseUrl = 'https://battleships-app.onrender.com';

  @override
  void initState() {
    super.initState();
    loadGame(); // load the game info when the screen opens
  }

  // This gets the latest game info from the server
  Future<void> loadGame() async {
    final token = await SessionManager.getSessionToken();
    final url = Uri.parse('$baseUrl/games/${widget.gameId}');

    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newHits = List<String>.from(data['sunk']);
      final newWrecks = List<String>.from(data['wrecks']);

      // Check if the game is over (5 ships sunk or lost)
      if (!gameOverShown) {
        if (newHits.length >= 5) {
          gameOver = true;
          _showGameOverDialog('🎉 You Won!');
        } else if (newWrecks.length >= 5) {
          gameOver = true;
          _showGameOverDialog('💀 You Lost!');
        }
      }

      setState(() {
        ships = List<String>.from(data['ships']);
        hits = newHits;
        misses = List<String>.from(data['shots']);
        wrecks = newWrecks;
        isUserTurn = data['turn'] == data['position']; // check if it's your turn
        isLoading = false;
      });
    }
  }

  // show a popup when the game ends
  void _showGameOverDialog(String message) {
    gameOverShown = true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // This is called when you try to shoot at a cell
  Future<void> fireShot(String pos) async {
    // don't let the user shoot the same spot twice
    if (hits.contains(pos) || misses.contains(pos)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shot already played')),
      );
      return;
    }

    final token = await SessionManager.getSessionToken();
    final url = Uri.parse('$baseUrl/games/${widget.gameId}');
    final res = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'shot': pos}),
    );

    if (res.statusCode == 200) {
      await loadGame(); // reload the board after shooting
      setState(() => shotPending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Game')),
        body: isLoading
            ? const Center(child: CircularProgressIndicator()) // show loading spinner
            : Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    gameOver
                        ? 'Game Over'
                        : isUserTurn
                            ? 'Your Turn'
                            : 'Opponent\'s Turn',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Make the board fit the screen
                        final gridSize = constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                        return Center(
                          child: SizedBox(
                            width: gridSize,
                            height: gridSize,
                            child: GridWithLabels(
                              buildCell: (pos) {
                                // Figure out what to show in each cell
                                final isShip = ships.contains(pos);
                                final isHit = hits.contains(pos);
                                final isMiss = misses.contains(pos);
                                final isWreck = wrecks.contains(pos);
                                final isSelected = shotPending == pos;

                                Color cellColor;
                                if (isSelected) {
                                  cellColor = Colors.teal;
                                } else if (isHit) {
                                  cellColor = Colors.redAccent;
                                } else if (isMiss) {
                                  cellColor = Colors.grey;
                                } else if (isWreck) {
                                  cellColor = Colors.black26;
                                } else if (isShip) {
                                  cellColor = Colors.yellow;
                                } else {
                                  cellColor = Colors.blue;
                                }

                                // Use emojis to show what's in the cell
                                String emoji = '';
                                if (isWreck && isHit) emoji = '💦💥';
                                else if (isWreck && isMiss) emoji = '💦💣';
                                else if (isShip && isHit) emoji = '🚢💥';
                                else if (isShip && isMiss) emoji = '🚢💣';
                                else if (isHit) emoji = '💥';
                                else if (isMiss) emoji = '💣';
                                else if (isWreck) emoji = '💦';
                                else if (isShip) emoji = '🚢';

                                return GestureDetector(
                                  onTap: () {
                                    // Only let you pick a cell if it's your turn and the game isn't over
                                    if (!gameOver && isUserTurn) {
                                      setState(() => shotPending = pos);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: cellColor,
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Center(
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: (!gameOver && shotPending != null && isUserTurn)
                  ? () => fireShot(shotPending!)
                  : null,
              child: const Text('Fire!'),
            ),
          ),
        ),
      ),
    );
  }
}
