import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../database/db_helper.dart';

// class to load sample flashcards from JSON
class JSONLoader {
  final DBHelper dbHelper;

  JSONLoader({required this.dbHelper});

  // reads the JSON file and inserts its content into the DB
  Future<void> loadFromAsset() async {
    // load the JSON file as a string
    final String jsonString = await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> data = jsonDecode(jsonString);

    // loop through each deck from JSON
    for (final dynamic deckMap in data) {
      final deckTitle = deckMap['title'] as String;
      final List<dynamic> cards = deckMap['flashcards'];

      // insert new deck to DB
      final newDeck = Deck(title: deckTitle, createdAt: DateTime.now());
      final deckId = await dbHelper.insertDeck(newDeck);

      // add each flashcard to that deck
      for (final flashcard in cards) {
        final question = flashcard['question'];
        final answer = flashcard['answer'];

        final newCard = Flashcard(
          deckId: deckId,
          question: question,
          answer: answer,
        );
        await dbHelper.insertFlashcard(newCard);
      }
    }
  }
}
