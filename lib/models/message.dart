/// Bir sohbet mesajını temsil eden model
class Message {
  /// Mesajın metni
  final String text;

  /// Mesajın kullanıcı tarafından mı gönderildiği
  final bool isUser;

  /// Mesajın animasyonunun tamamlanıp tamamlanmadığı
  bool isAnimated;

  Message({
    required this.text,
    required this.isUser,
    this.isAnimated = false,
  });
} 