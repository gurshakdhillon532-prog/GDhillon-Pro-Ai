import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final String sender; // 'user' or 'assistant'
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      sender: map['sender'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, HH:mm').format(timestamp);
    }
  }

  bool get isUser => sender == 'user';
  bool get isAssistant => sender == 'assistant';
}
