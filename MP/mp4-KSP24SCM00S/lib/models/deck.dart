// This model represents a deck of flashcards
class Deck {
  final int? id;               
  final String title;          
  final DateTime? createdAt;

  Deck({
    this.id,
    required this.title,
    this.createdAt,
  });

  // Convert DB map to Deck object
  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      title: map['title'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }

  // Convert Deck object to map for DB storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
