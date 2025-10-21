// lib/models/scorecard.dart
import 'package:collection/collection.dart';

// for each yahtzee scoring category with a display name
enum ScoreCategory {
  ones("Ones"),
  twos("Twos"),
  threes("Threes"),
  fours("Fours"),
  fives("Fives"),
  sixes("Sixes"),
  threeOfAKind("Three of a Kind"),
  fourOfAKind("Four of a Kind"),
  fullHouse("Full House"),
  smallStraight("Small Straight"),
  largeStraight("Large Straight"),
  yahtzee("Yahtzee"),
  chance("Chance");

  const ScoreCategory(this.name);
  final String name; // string label for displaying in UI
}


class ScoreCard {
  // Map to store each score category and its value (null if not filled yet)
  final Map<ScoreCategory, int?> _scores = {
    for (var category in ScoreCategory.values) category: null
  };

  // allows using scoreCard[category] to get the score
  int? operator [](ScoreCategory category) => _scores[category];

  // Check if all categories are filled (game complete)
  bool get completed => _scores.values.whereNotNull().length == _scores.length;

  // sum of all filled-in scores
  int get total => _scores.values.whereNotNull().sum;

  // resets all scores to null (clears the board)
  void clear() {
    _scores.forEach((key, value) {
      _scores[key] = null;
    });
  }

  // Calculates and stores score for a selected category based on current dice
  void registerScore(ScoreCategory category, List<int> dice) {
    final uniqueVals = Set.from(dice); // Unique dice values for pattern checks

    if (_scores[category] != null) {
      throw Exception('Category $category already has a score');
    }

    switch (category) {
      case ScoreCategory.ones:
        _scores[category] = dice.where((d) => d == 1).sum;
        break;

      case ScoreCategory.twos:
        _scores[category] = dice.where((d) => d == 2).sum;
        break;

      case ScoreCategory.threes:
        _scores[category] = dice.where((d) => d == 3).sum;
        break;
        
      case ScoreCategory.fours:
        _scores[category] = dice.where((d) => d == 4).sum;
        break;

      case ScoreCategory.fives:
        _scores[category] = dice.where((d) => d == 5).sum;
        break;

      case ScoreCategory.sixes:
        _scores[category] = dice.where((d) => d == 6).sum;
        break;

      case ScoreCategory.threeOfAKind:
        // if any number appears at least 3 times
        _scores[category] = dice.any((d) => dice.where((d2) => d2 == d).length >= 3) ? dice.sum : 0;
        break;

      case ScoreCategory.fourOfAKind:
        // if any number appears at least 4 times
        _scores[category] = dice.any((d) => dice.where((d2) => d2 == d).length >= 4) ? dice.sum : 0;
        break;

      case ScoreCategory.fullHouse:
        // 3 of one number + 2 of another
        if (uniqueVals.length == 2 && uniqueVals.any((d) => dice.where((d2) => d2 == d).length == 3)) {
          _scores[category] = 25;
        } else {
          _scores[category] = 0;
        }
        break;

      case ScoreCategory.smallStraight:
        // any 4-number sequence
        if (uniqueVals.containsAll([1, 2, 3, 4]) ||
            uniqueVals.containsAll([2, 3, 4, 5]) ||
            uniqueVals.containsAll([3, 4, 5, 6])) {
          _scores[category] = 30;
        } else {
          _scores[category] = 0;
        }
        break;

      case ScoreCategory.largeStraight:
        // Any 5-number sequence
        if (uniqueVals.containsAll([1, 2, 3, 4, 5]) ||
            uniqueVals.containsAll([2, 3, 4, 5, 6])) {
          _scores[category] = 40;
        } else {
          _scores[category] = 0;
        }
        break;

      case ScoreCategory.yahtzee:
        // All 5 dice show the same number
        _scores[category] = (dice.length == 5 && uniqueVals.length == 1) ? 50 : 0;
        break;

      case ScoreCategory.chance:
        // No pattern needed, add all dice
        _scores[category] = dice.sum;
        break;
    }
  }
}
