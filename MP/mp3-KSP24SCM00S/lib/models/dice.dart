// lib/models/dice.dart
import 'dart:math';

class Dice {
  final List<int?> _values; // stores the value of each die
  final List<bool> _held; // keeps track of which dice are held
  final Random _random = Random(); // for generating random dice rolls

  Dice(int count)
      : _values = List<int?>.filled(count, null),
        _held = List<bool>.filled(count, false);

  // used by UI to show current dice values
  List<int?> get values => _values;

  // bracket access like _dice[2] to get value at index 2
  int? operator [](int index) => _values[index];

  // flips the held status of a die
  void toggleHold(int index) {
    _held[index] = !_held[index];
  }

  // Check if a die is held or not
  bool isHeld(int index) => _held[index];

  // roll all dice that aren’t held
  void roll() {
    for (int i = 0; i < _values.length; i++) {
      if (!_held[i]) {
        _values[i] = _random.nextInt(6) + 1; // 1 to 6
      }
    }
  }

  // wipe all dice and unhold everything, imp when round ends or game resets
  void clear() {
    for (int i = 0; i < _values.length; i++) {
      _values[i] = null;
      _held[i] = false;
    }
  }

  // let the UI know how many dice we have
  int get length => _values.length;
}
