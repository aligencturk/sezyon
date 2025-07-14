/// Sohbet mesajını temsil eden model sınıfı
class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// JSON'dan Message nesnesi oluşturur
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Message nesnesini JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Kullanıcı mesajı oluşturur
  factory Message.user(String content) {
    return Message(content: content, isUser: true);
  }

  /// AI mesajı oluşturur
  factory Message.ai(String content) {
    return Message(content: content, isUser: false);
  }
} 