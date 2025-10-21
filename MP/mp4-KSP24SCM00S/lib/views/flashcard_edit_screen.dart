import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_styles.dart';
import '../database/db_helper.dart';

// Page to add or edit a flashcard
class FlashcardEditScreen extends StatefulWidget {
  final int deckId;
  final Flashcard? existingCard;

  const FlashcardEditScreen({
    Key? key,
    required this.deckId,
    this.existingCard,
  }) : super(key: key);

  @override
  State<FlashcardEditScreen> createState() => _FlashcardEditScreenState();
}

class _FlashcardEditScreenState extends State<FlashcardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
        text: widget.existingCard?.question ?? '');
    _answerController = TextEditingController(
        text: widget.existingCard?.answer ?? '');
  }

  // Save or update the flashcard
  Future<void> _saveFlashcard() async {
    if (_formKey.currentState!.validate()) {
      final question = _questionController.text.trim();
      final answer = _answerController.text.trim();

      if (widget.existingCard == null) {
        final newCard = Flashcard(
          deckId: widget.deckId,
          question: question,
          answer: answer,
        );
        await dbHelper.insertFlashcard(newCard);
      } else {
        await dbHelper.updateFlashcard(
          widget.existingCard!.id!,
          question,
          answer,
        );
      }

      Navigator.pop(context, true);
    }
  }

  // Delete the card if editing
  Future<void> _deleteFlashcard() async {
    if (widget.existingCard != null) {
      await dbHelper.deleteFlashcard(widget.existingCard!.id!);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCard != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Flashcard' : 'Add Flashcard',
            style: AppFonts.heading),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Text field for the question
              TextFormField(
                controller: _questionController,
                style: AppFonts.body,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a question'
                    : null,
              ),
              const SizedBox(height: 20),

              // Text field for the answer
              TextFormField(
                controller: _answerController,
                style: AppFonts.body,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter an answer'
                    : null,
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton.icon(
                onPressed: _saveFlashcard,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: AppStyles.elevatedButtonStyle,
              ),

              // Show delete option only when editing
              if (isEditing)
                TextButton.icon(
                  onPressed: _deleteFlashcard,
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  label: const Text(
                    'Delete Flashcard',
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
