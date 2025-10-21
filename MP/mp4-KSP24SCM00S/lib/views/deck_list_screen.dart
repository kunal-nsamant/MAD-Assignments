import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';
import '../widgets/deck_card.dart';
import '../widgets/responsive_layout.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../database/db_helper.dart';
import '../services/json_loader.dart';
import 'deck_edit_screen.dart';
import 'flashcard_list_screen.dart';

// Deck list is the main home screen of the app
enum SortOrder { byDate, byAlphabet }

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({Key? key}) : super(key: key);

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  final dbHelper = DBHelper();
  late final JSONLoader jsonLoader;

  List<Deck> decks = [];
  bool isLoading = true;
  SortOrder sortOrder = SortOrder.byDate;

  @override
  void initState() {
    super.initState();
    jsonLoader = JSONLoader(dbHelper: dbHelper);
    _loadDecks(); // load decks from DB or JSON on first run
  }

  // load all decks and check if JSON needs to be loaded
  Future<void> _loadDecks() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;

    // load sample decks if app is opened for the first time
    if (isFirstRun) {
      await jsonLoader.loadFromAsset();
      await prefs.setBool('isFirstRun', false);
    }

    final loadedDecks = await dbHelper.getAllDecks();
    setState(() {
      decks = loadedDecks;
      _sortDecks();
      isLoading = false;
    });
  }

  // manually load sample decks again
  Future<void> _importFromJSON() async {
    await jsonLoader.loadFromAsset();
    await _loadDecks();
  }

  // open screen to add or edit deck
  void _navigateToEditDeck({Deck? deck}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeckEditScreen(existingDeck: deck)),
    );
    if (result == true) await _loadDecks(); // reload if anything changed
  }

  // ask for confirmation before deleting a deck
  void _confirmDeleteDeck(Deck deck) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Deck'),
        content: const Text('Are you sure you want to delete this deck?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await dbHelper.deleteDeck(deck.id!);
              await _loadDecks();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // navigate to flashcards of selected deck
  void _openDeck(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlashcardListScreen(deck: deck)),
    );
  }

  // toggle between alphabetical and date sorting
  void _toggleSortOrder() {
    setState(() {
      sortOrder = sortOrder == SortOrder.byDate ? SortOrder.byAlphabet : SortOrder.byDate;
      _sortDecks();
    });
  }

  // sort decks in the selected order
  void _sortDecks() {
    if (sortOrder == SortOrder.byAlphabet) {
      decks.sort((a, b) => a.title.compareTo(b.title));
    } else {
      decks.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('My Decks', style: AppFonts.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: _toggleSortOrder,
            tooltip: 'Toggle Sort Order',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _importFromJSON,
            tooltip: 'Load Sample Decks',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ResponsiveLayout(
                builder: (context, columns) => GridView.builder(
                  itemCount: decks.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (_, index) {
                    final deck = decks[index];
                    return DeckCard(
                      deck: deck,
                      onTap: () => _openDeck(deck),
                      onEdit: () => _navigateToEditDeck(deck: deck),
                      onDelete: () => _confirmDeleteDeck(deck),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _navigateToEditDeck(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
