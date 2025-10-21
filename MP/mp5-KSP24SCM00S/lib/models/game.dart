// This class is just for holding info about a single game
class Game {
  final int id; // game id
  final String player1; // first player
  final String? player2; // second player (can be null if waiting)
  final int turn; // whose turn
  final int status; // 0 = waiting, 1 = p1 won, 2 = p2 won, 3 = playing
  final int position; // your position

  Game({
    required this.id,
    required this.player1,
    this.player2,
    required this.position,
    required this.status,
    required this.turn,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      player1: json['player1'],
      player2: json['player2'] as String?,
      position: json['position'],
      status: json['status'],
      turn: json['turn'],
    );
  }
}
