import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/session_manager.dart';
import 'game_list_screen.dart';
import 'package:provider/provider.dart';
import '../models/game_list_notifier.dart';

// This is the login/register screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String baseUrl = 'https://battleships-app.onrender.com';

  // show a message at the bottom of the screen
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // check if the username and password
  bool _isValidInput(String username, String password) {
    return username.length >= 3 &&
        password.length >= 3 &&
        !username.contains(' ') &&
        !password.contains(' ');
  }

  // when you try to login or register
  Future<void> _authenticate(String type) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (!_isValidInput(username, password)) {
      _showMessage('Username and password must be at least 3 characters and contain no spaces.');
      return;
    }

    final url = Uri.parse('$baseUrl/$type');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      await SessionManager.setSessionToken(token); // save the token
      await SessionManager.setUsername(username); // save the username
      // Force refresh the game list for the new user
      await Provider.of<GameListNotifier>(context, listen: false).fetchGames();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameListScreen()),
      );
    } else {
      String errorMsg;
      if (type == 'login') {
        errorMsg = 'Login Failed';
      } else if (type == 'register') {
        errorMsg = 'Registration Failed';
      } else {
        errorMsg = 'Error: ${jsonDecode(response.body)['message'] ?? 'Invalid credentials'}';
      }
      _showMessage(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Battleships Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _authenticate('login'), // try to login
                child: const Text('Login'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _authenticate('register'), // try to register
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
