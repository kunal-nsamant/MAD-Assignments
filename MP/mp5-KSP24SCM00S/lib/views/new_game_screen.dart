import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/session_manager.dart';
import 'components/grid_with_labels.dart';

// This screen lets you place your ships and start a new game
class NewGameScreen extends StatefulWidget {
  final String? aiType; // which AI to play against

  const NewGameScreen({super.key, this.aiType});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  List<String> selected = []; // where you put your ships
  final String baseUrl = 'https://battleships-app.onrender.com';

  // Add or remove a ship from the board
  void toggleCell(String pos) {
    setState(() {
      if (selected.contains(pos)) {
        selected.remove(pos); // remove if already there
      } else if (selected.length < 5) {
        selected.add(pos); // add if less than 5 ships
      }
    });
  }

  // Start the game by sending your ship positions to the server
  Future<void> startGame() async {
    final token = await SessionManager.getSessionToken();
    final url = Uri.parse('$baseUrl/games');

    final body = {
      'ships': selected,
      if (widget.aiType != null) 'ai': widget.aiType, // add AI if chosen
    };

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      Navigator.pop(context, true); // go back to the game list and signal refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start game: ${res.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Place Ships'));
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        body: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Make the grid fit the screen
                  final gridSize = constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
                  return Center(
                    child: SizedBox(
                      width: gridSize,
                      height: gridSize,
                      child: GridWithLabels(
                        buildCell: (pos) {
                          final isSelected = selected.contains(pos);
                          return GestureDetector(
                            onTap: () => toggleCell(pos), // add orremove ship
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.yellow : Colors.blue,
                                border: Border.all(color: Colors.black),
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: selected.length == 5 ? startGame : null, // only start if 5 ships
            child: const Text('Start Game'),
          ),
        ),
      ),
    );
  }
}
