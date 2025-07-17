/// Bir sohbet mesajını temsil eden model
class Message {
  /// Mesajın metni
  final String text;

  /// Mesajın kullanıcı tarafından mı gönderildiği
  final bool isUser;

  /// Mesajın animasyonunun tamamlanıp tamamlanmadığı
  bool isAnimated;

  /// Mesajın seçenekler içerip içermediği
  final bool hasChoices;

  /// Mesajın seçenekleri (eğer varsa)
  final List<Choice>? choices;

  Message({
    required this.text,
    required this.isUser,
    this.isAnimated = false,
    this.hasChoices = false,
    this.choices,
  });
}

/// Hikaye seçeneklerini temsil eden model
class Choice {
  /// Seçeneğin metni
  final String text;

  /// Seçeneğin benzersiz kimliği
  final String id;

  /// Seçeneğin seçilip seçilmediği
  bool isSelected;

  Choice({
    required this.text,
    required this.id,
    this.isSelected = false,
  });
} 