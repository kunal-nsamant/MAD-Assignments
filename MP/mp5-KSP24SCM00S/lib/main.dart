import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_list_notifier.dart';
import 'views/battleships_app.dart';

void main() {
  // This is where the app starts running
  runApp(
    // share game list updates everywhere in the app
    ChangeNotifierProvider(
      create: (_) => GameListNotifier(), // makes a notifier for all games
      child: const BattleshipsApp(), // this is our main app widget
    ),
  );
}
