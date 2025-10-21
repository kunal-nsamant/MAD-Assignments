import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

// Widget to show a single flashcard in quiz or list mode
class FlashcardCard extends StatelessWidget {
  final Flashcard flashcard;
  final bool showAnswer;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const FlashcardCard({
    Key? key,
    required this.flashcard,
    required this.showAnswer,
    required this.onTap,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Stack(
            children: [
              // edit icon on top-right
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.text),
                  onPressed: onEdit,
                ),
              ),
              // show question or answer at center
              Center(
                child: Text(
                  showAnswer ? flashcard.answer : flashcard.question,
                  style: AppFonts.body.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
