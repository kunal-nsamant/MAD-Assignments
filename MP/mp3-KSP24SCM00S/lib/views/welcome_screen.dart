// lib/views/welcome_screen.dart
import 'package:flutter/material.dart';
import 'yahtzee.dart';

// This screen is shown first and displays a loading bar
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _progress = 0; // value of the loading bar (0 to 1)

  @override
  void initState() {
    super.initState();
    _simulateLoading(); // loading animation
  }

  void _simulateLoading() {
    // loading effect by incrementing progress in small steps
    Future.delayed(const Duration(milliseconds: 30), () {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.02;
        });
        _simulateLoading(); // recursively call to continue loading
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // accessing theme styles

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // background
          gradient: LinearGradient(
            colors: [Colors.grey, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // title text
            Text(
              'Welcome to Yahtzee!',
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // dice icon inside red rounded box
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.casino, color: Colors.yellow, size: 50),
              ),
            ),
            const SizedBox(height: 30),

            // Progress bar
            LinearProgressIndicator(
              value: _progress,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: Colors.yellow[700],
            ),
            const SizedBox(height: 10),

            // Show current loading percentage
            Text(
              '${(_progress * 100).toInt()}% Ready',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 40),

            // Button becomes enabled when progress is full
            ElevatedButton.icon(
              onPressed: _progress >= 1
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const YahtzeeGame()),
                      );
                    }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Ready, Set, Roll!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),

            // footer text
            const Text(
              'Roll the dice, climb the leaderboard!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
