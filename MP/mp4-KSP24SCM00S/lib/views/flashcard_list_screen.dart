import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../database/db_helper.dart';
import '../widgets/flashcard_card.dart';
import '../widgets/responsive_layout.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'flashcard_edit_screen.dart';
import 'quiz_screen.dart';

// Screen that shows all flashcards in a selected deck
enum FlashcardSortOrder { byDate, byAlphabet }

class FlashcardListScreen extends StatefulWidget {
  final Deck deck;

  const FlashcardListScreen({Key? key, required this.deck}) : super(key: key);

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {
  final dbHelper = DBHelper();
  List<Flashcard> flashcards = [];
  Map<int, bool> showAnswers = {};
  bool isLoading = true;
  FlashcardSortOrder sortOrder = FlashcardSortOrder.byDate;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  // Load all flashcards for this deck
  Future<void> _loadFlashcards() async {
    setState(() => isLoading = true);
    final cards = await dbHelper.getFlashcardsByDeckId(widget.deck.id!);
    setState(() {
      flashcards = cards;
      _sortFlashcards();
      // Init answer visibility
      showAnswers = {for (var card in cards) card.id!: false};
      isLoading = false;
    });
  }

  // Toggle answer visibility for a flashcard
  void _toggleAnswer(int id) {
    setState(() {
      showAnswers[id] = !(showAnswers[id] ?? false);
    });
  }

  // Open editor to add or update flashcard
  void _openEditor({Flashcard? flashcard}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardEditScreen(
          deckId: widget.deck.id!,
          existingCard: flashcard,
        ),
      ),
    );
    if (result == true) await _loadFlashcards(); // Reload if changed
  }

  // Start quiz for current deck
  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(flashcards: flashcards),
      ),
    );
  }

  // switch sorting mode
  void _toggleSortOrder() {
    setState(() {
      sortOrder = sortOrder == FlashcardSortOrder.byDate
          ? FlashcardSortOrder.byAlphabet
          : FlashcardSortOrder.byDate;
      _sortFlashcards();
    });
  }

  // Sort flashcards alphabetically or by creation order
  void _sortFlashcards() {
    if (sortOrder == FlashcardSortOrder.byAlphabet) {
      flashcards.sort((a, b) => a.question.compareTo(b.question));
    } else {
      flashcards.sort((a, b) => a.id!.compareTo(b.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.deck.title, style: AppFonts.heading),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: _toggleSortOrder,
            tooltip: 'Sort Flashcards',
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: flashcards.isEmpty ? null : _startQuiz,
            tooltip: 'Start Quiz',
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ResponsiveLayout(
                builder: (context, columns) => GridView.builder(
                  itemCount: flashcards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, index) {
                    final card = flashcards[index];
                    return FlashcardCard(
                      flashcard: card,
                      showAnswer: showAnswers[card.id] ?? false,
                      onTap: () => _toggleAnswer(card.id!),
                      onEdit: () => _openEditor(flashcard: card),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
