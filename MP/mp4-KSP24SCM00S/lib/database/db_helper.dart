import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static const _dbName = 'flashcards.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE deck (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcard (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        FOREIGN KEY(deck_id) REFERENCES deck(id) ON DELETE CASCADE
      )
    ''');
  }

  // ─── Deck CRUD ────────────────────────────────────────────────────────────────

  Future<int> insertDeck(Deck deck) async {
    final db = await database;

    
    return await db.insert('deck', deck.toMap());
  }

  Future<List<Deck>> getAllDecks() async {
    final db = await database;
    final maps = await db.query('deck', orderBy: 'id DESC');
    return maps.map((map) => Deck.fromMap(map)).toList();
  }

  Future<void> updateDeckTitle(int deckId, String newTitle) async {
    final db = await database;
    await db.update(
      'deck',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  Future<void> deleteDeck(int deckId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('flashcard', where: 'deck_id = ?', whereArgs: [deckId]);
      await txn.delete('deck', where: 'id = ?', whereArgs: [deckId]);
    });
  }

  // ─── Flashcard CRUD ──────────────────────────────────────────────────────────

  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.insert('flashcard', flashcard.toMap());
  }

  Future<List<Flashcard>> getFlashcardsByDeckId(int deckId) async {
    final db = await database;
    final maps = await db.query(
      'flashcard',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
    return maps.map((map) => Flashcard.fromMap(map)).toList();
  }

  Future<void> updateFlashcard(int id, String question, String answer) async {
    final db = await database;
    await db.update(
      'flashcard',
      {'question': question, 'answer': answer},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFlashcard(int id) async {
    final db = await database;
    await db.delete(
      'flashcard',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getFlashcardCount(int deckId) async {
    final db = await database;
    final result = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM flashcard WHERE deck_id = ?',
      [deckId],
    ));
    return result ?? 0;
  }
}
