import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/session_manager.dart';
import 'game.dart';

// This class keeps track of all your games and updates the UI when things change
class GameListNotifier extends ChangeNotifier {
  final String baseUrl = 'https://battleships-app.onrender.com';
  List<Game> games = []; // all your games
  bool isLoading = true;

  GameListNotifier() {
    fetchGames(); // get games when this is made
  }

  // Get the list of games from the server
  Future<bool> fetchGames() async {
    isLoading = true;
    notifyListeners(); // tell the UI to show loading

    final token = await SessionManager.getSessionToken();
    if (token.isEmpty) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> gamesJson = data['games'];
      games = gamesJson.map((json) => Game.fromJson(json)).toList();
      games.sort((a, b) => b.id.compareTo(a.id)); // newest games first
    }

    isLoading = false;
    notifyListeners(); // update the UI
    return response.statusCode == 200;
  }

  // Remove a game from the list if you forfeit
  void removeGame(int gameId) {
    games.removeWhere((g) => g.id == gameId);
    notifyListeners();
  }
}
