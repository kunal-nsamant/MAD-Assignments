// lib/views/yahtzee.dart
import 'package:flutter/material.dart';
import 'package:mp3_yahtzee/models/dice.dart';
import 'package:mp3_yahtzee/models/scorecard.dart';

class YahtzeeGame extends StatefulWidget {
  const YahtzeeGame({super.key});

  @override
  State<YahtzeeGame> createState() => _YahtzeeGameState();
}

class _YahtzeeGameState extends State<YahtzeeGame> {
  final Dice _dice = Dice(5); // create 5 dice
  final ScoreCard _scoreCard = ScoreCard(); // Create a new scorecard
  int _rollsLeft = 3; // Player gets max 3 rolls per round

  // Called when user taps "Roll Dice"
  void _rollDice() {
    if (_rollsLeft > 0) {
      setState(() {
        _dice.roll(); // roll unheld dice
        _rollsLeft--;
      });
    }
  }

  // called when user taps a die (to hold or release it)
  void _toggleHold(int index) {
    setState(() {
      _dice.toggleHold(index);
    });
  }

  // called when user selects a scoring category
  void _selectCategory(ScoreCategory category) {
    final values = _dice.values;

    if (_scoreCard[category] == null && !values.contains(null)) {
      setState(() {
        _scoreCard.registerScore(category, values.cast<int>());
        _dice.clear(); // clear dice for next round
        _rollsLeft = 3;
      });

      // if all categories are filled, game is over
      if (_scoreCard.completed) {
        _showFinalScoreDialog();
      }
    }
  }

  // resets the whole game (dice, scores, rolls)
  void _resetGame() {
    setState(() {
      _dice.clear();
      _scoreCard.clear();
      _rollsLeft = 3;
    });
  }

  // Show popup with final score and play again button
  void _showFinalScoreDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Final Score: ${_scoreCard.total}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  // UI for displaying dice horizontally
  Widget _buildDiceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_dice.length, (index) {
        final value = _dice[index];
        final isHeld = _dice.isHeld(index);

        return GestureDetector(
          onTap: () => _toggleHold(index),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHeld ? Colors.teal[300] : Colors.teal[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              value?.toString() ?? '🎲',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  // build button UI for each score category
  Widget _buildCategoryButton(ScoreCategory category) {
    final score = _scoreCard[category];
    final name = category.name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: score == null ? Colors.white : Colors.grey[200],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text('$name: ${score?.toString() ?? "-"}')),
          if (score == null)
            ElevatedButton(
              onPressed: () => _selectCategory(category),
              child: const Text('Select'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yahtzee Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Game',
            onPressed: _resetGame,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDiceRow(), // shows dice row
              const SizedBox(height: 8),
              Text('Remaining Rolls: $_rollsLeft', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _rollsLeft > 0 ? _rollDice : null,
                child: const Text('Roll Dice'),
              ),
              const Divider(height: 10),

              // show all score category buttons in a responsive layout
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: ScoreCategory.values.map((cat) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child: _buildCategoryButton(cat),
                  );
                }).toList(),
              ),

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Current Score: ${_scoreCard.total}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
