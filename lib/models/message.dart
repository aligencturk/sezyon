/// Hikaye aşamalarını temsil eden enum
enum StoryPhase {
  introduction, // Giriş - Durumun tanıtılması
  development, // Gelişme - Olayların gelişmesi
  climax, // Doruk - Ana çatışma/karar anı
  conclusion, // Sonuç - Hikayenin sonu
  epilogue, // Epilog - Hikaye sonrası devam
}

/// Hikaye sonu türlerini temsil eden enum
enum StoryEndType {
  complete, // Tamamen bitti
  canContinue, // Devam edilebilir
}

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

  /// Hikayenin mevcut aşaması
  final StoryPhase? storyPhase;

  /// Hikayenin sonlanıp sonlanmadığı
  final bool isStoryEnd;

  /// Hikaye sonu türü
  final StoryEndType? storyEndType;

  /// Hikaye özeti (credits benzeri)
  final String? storySummary;

  /// Epilog aşamasında mı
  final bool isEpilogue;

  Message({
    required this.text,
    required this.isUser,
    this.isAnimated = false,
    this.hasChoices = false,
    this.choices,
    this.storyPhase,
    this.isStoryEnd = false,
    this.storyEndType,
    this.storySummary,
    this.isEpilogue = false,
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

  Choice({required this.text, required this.id, this.isSelected = false});
}
