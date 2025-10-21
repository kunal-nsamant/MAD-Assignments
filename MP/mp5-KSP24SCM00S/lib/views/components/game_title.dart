import 'package:flutter/material.dart';
import '../../models/game.dart';

// This widget shows a single game in the list
class GameTile extends StatelessWidget {
  final Game game; // the game info
  final VoidCallback onTap; // what to do when you tap the game
  final VoidCallback? onDelete; // what to do when you want to delete the game
  final String currentUser; // the username of the person using the app

  // Constructor for GameTile, takes all the stuff above
  const GameTile({
    super.key,
    required this.game,
    required this.onTap,
    required this.currentUser,
    this.onDelete,
  });

  // Figure out what text to show for the game's status
  String _getStatusText() {
    final isCompleted = game.status == 1 || game.status == 2;

    if (isCompleted) {
      if ((game.status == 1 && game.player1 == currentUser) ||
          (game.status == 2 && game.player2 == currentUser)) {
        return 'You Won';
      } else {
        return 'You Lost';
      }
    }

    if (game.status == 0) return 'Waiting for Opponent';
    if (game.status == 3) {
      // heck if it's your turn
      // The backend gives us 'position' for the current player
      // and "turn" is whose turn it is (also 1 or 2)
      // So if they match, it's your turn
      return game.turn == game.position ? 'Your Turn' : 'Opponent\'s Turn';
    }
    return '...';
  }

  @override
  Widget build(BuildContext context) {
    // figure out if the game is over
    final isCompleted = game.status == 1 || game.status == 2;

    // this is the actual tile you see in the list
    return ListTile(
      title: Text('Game ID: ${game.id}'), // shows the game id
      subtitle: Text('${game.player1} vs ${game.player2 ?? 'Waiting'}'), // shows who is playing
      leading: Text(
        _getStatusText(), // shows the status (your turn, opponent's turn, etc)
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // only show the delete button if the game isn't over and you can delete
          if (!isCompleted && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          // Always show the arrow
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap, // what happens when you tap the tile
    );
  }
}
