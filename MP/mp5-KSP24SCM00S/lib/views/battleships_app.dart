import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import 'login_screen.dart';
import 'game_list_screen.dart';

// this is the app widget that decides what screen to show first
class BattleshipsApp extends StatefulWidget {
  const BattleshipsApp({super.key});

  @override
  State<BattleshipsApp> createState() => _BattleshipsAppState();
}

class _BattleshipsAppState extends State<BattleshipsApp> {
  bool _isLoggedIn = false; // is the player logged in

  @override
  void initState() {
    super.initState();
    _checkSession(); // check if the player is logged in
  }

  // see if the user is logged in by checking the session
  Future<void> _checkSession() async {
    final isLogged = await SessionManager.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLogged;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battleships',
      home: _isLoggedIn ? const GameListScreen() : const LoginScreen(), // show login or game list
    );
  }
}
