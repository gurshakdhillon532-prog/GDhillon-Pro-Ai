class ClipboardItem {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isFavorite;
  final String? category;
  final int charCount;

  ClipboardItem({
    required this.id,
    required this.content,
    required this.timestamp,
    this.isFavorite = false,
    this.category,
    required this.charCount,
  });

  ClipboardItem copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    bool? isFavorite,
    String? category,
    int? charCount,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      charCount: charCount ?? this.charCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
      'category': category,
      'charCount': charCount,
    };
  }

  factory ClipboardItem.fromMap(Map<String, dynamic> map) {
    return ClipboardItem(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      isFavorite: map['isFavorite'] ?? false,
      category: map['category'],
      charCount: map['charCount'] ?? 0,
    );
  }
}
