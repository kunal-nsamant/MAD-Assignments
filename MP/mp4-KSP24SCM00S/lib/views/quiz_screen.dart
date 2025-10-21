import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

// Quiz screen to review flashcards from a deck
class QuizScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const QuizScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Flashcard> shuffledCards;
  int currentIndex = 0;
  bool showAnswer = false;

  Set<int> seenCards = {};
  Set<int> peekedCards = {};

  @override
  void initState() {
    super.initState();
    shuffledCards = List<Flashcard>.from(widget.flashcards)..shuffle();
    _markSeen();
  }

  // Keep track of which card was seen
  void _markSeen() {
    seenCards.add(currentIndex);
  }

  // Toggle between question and answer
  void _toggleAnswer() {
    setState(() {
      showAnswer = !showAnswer;
      if (showAnswer) peekedCards.add(currentIndex);
    });
  }

  // Go to next card
  void _nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % shuffledCards.length;
      showAnswer = false;
      _markSeen();
    });
  }

  // Go back to previous card
  void _previousCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + shuffledCards.length) %
          shuffledCards.length;
      showAnswer = false;
      _markSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = shuffledCards[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quiz Mode', style: AppFonts.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Flashcard box
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: showAnswer ? AppColors.accent : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.text.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(24),
                child: Text(
                  showAnswer ? currentCard.answer : currentCard.question,
                  style: AppFonts.body.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.primary,
                  onPressed: _previousCard,
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  color: AppColors.primary,
                  onPressed: _toggleAnswer,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  color: AppColors.primary,
                  onPressed: _nextCard,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Seen and peeked stats
            Text(
              'Seen: ${seenCards.length} / ${shuffledCards.length}',
              style: AppFonts.body,
            ),
            Text(
              'Peeked: ${peekedCards.length} / ${seenCards.length}',
              style: AppFonts.body,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
