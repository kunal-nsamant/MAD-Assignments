import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_styles.dart';
import '../database/db_helper.dart';

// Screen to add a new deck or edit an existing one
class DeckEditScreen extends StatefulWidget {
  final Deck? existingDeck;

  const DeckEditScreen({Key? key, this.existingDeck}) : super(key: key);

  @override
  State<DeckEditScreen> createState() => _DeckEditScreenState();
}

class _DeckEditScreenState extends State<DeckEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingDeck?.title ?? '',
    );
  }

  // Save the deck title new or update
  Future<void> _saveDeck() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();

      if (widget.existingDeck == null) {
        final newDeck = Deck(title: title, createdAt: DateTime.now());
        await dbHelper.insertDeck(newDeck);
      } else {
        await dbHelper.updateDeckTitle(widget.existingDeck!.id!, title);
      }

      Navigator.pop(context, true);
    }
  }

  // delete this deck
  Future<void> _deleteDeck() async {
    if (widget.existingDeck != null) {
      await dbHelper.deleteDeck(widget.existingDeck!.id!);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDeck != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Deck' : 'Add Deck', style: AppFonts.heading),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // input for the deck title
              TextFormField(
                controller: _titleController,
                style: AppFonts.body,
                decoration: const InputDecoration(
                  labelText: 'Deck Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveDeck,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: AppStyles.elevatedButtonStyle,
              ),
              if (isEditing)
                TextButton.icon(
                  onPressed: _deleteDeck,
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  label: const Text(
                    'Delete Deck',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
