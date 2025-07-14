import '../services/language_service.dart';

/// Oyun kategorileri enum'u
enum GameCategory {
  war('war'),
  sciFi('sciFi'),
  history('history'),
  fantasy('fantasy');

  const GameCategory(this.key);
  final String key;

  /// Kategori adını döndürür
  String get displayName {
    final languageService = LanguageService();
    return languageService.getCategoryName(key);
  }

  /// Kategori için başlangıç prompt'u oluşturur
  String getInitialPrompt() {
    final languageService = LanguageService();
    
    if (languageService.isTurkish) {
      return _getTurkishInitialPrompt();
    } else {
      return _getEnglishInitialPrompt();
    }
  }

  /// Türkçe başlangıç prompt'u
  String _getTurkishInitialPrompt() {
    switch (this) {
      case GameCategory.war:
        return 'Sen bir savaş temalı RPG oyunu yöneticisisin. Türkçe olarak epik bir savaş hikayesi başlat. Oyuncu bir savaşçı olsun. Hikayeyi 2-3 paragrafta yaz ve sonunda oyuncuya 2-3 seçenek sun. Her seçeneği numaralandır.';
      case GameCategory.sciFi:
        return 'Sen bir bilim kurgu temalı RPG oyunu yöneticisisin. Türkçe olarak gelecekte geçen bir bilim kurgu hikayesi başlat. Oyuncu bir uzay yolcusu veya gelecek dünyasında yaşayan biri olsun. Hikayeyi 2-3 paragrafta yaz ve sonunda oyuncuya 2-3 seçenek sun. Her seçeneği numaralandır.';
      case GameCategory.history:
        return 'Sen bir tarih temalı RPG oyunu yöneticisisin. Türkçe olarak tarihi bir dönemde geçen bir hikaye başlat. Oyuncu tarihi bir karakter olsun. Hikayeyi 2-3 paragrafta yaz ve sonunda oyuncuya 2-3 seçenek sun. Her seçeneği numaralandır.';
      case GameCategory.fantasy:
        return 'Sen bir fantastik temalı RPG oyunu yöneticisisin. Türkçe olarak büyülü bir dünyada geçen fantastik bir hikaye başlat. Oyuncu bir maceracı, büyücü veya savaşçı olsun. Hikayeyi 2-3 paragrafta yaz ve sonunda oyuncuya 2-3 seçenek sun. Her seçeneği numaralandır.';
    }
  }

  /// İngilizce başlangıç prompt'u
  String _getEnglishInitialPrompt() {
    switch (this) {
      case GameCategory.war:
        return 'You are a war-themed RPG game master. Start an epic war story in English. The player should be a warrior. Write the story in 2-3 paragraphs and provide 2-3 numbered choices for the player at the end.';
      case GameCategory.sciFi:
        return 'You are a science fiction themed RPG game master. Start a sci-fi story set in the future in English. The player should be a space traveler or someone living in a futuristic world. Write the story in 2-3 paragraphs and provide 2-3 numbered choices for the player at the end.';
      case GameCategory.history:
        return 'You are a history-themed RPG game master. Start a historical story set in a historical period in English. The player should be a historical character. Write the story in 2-3 paragraphs and provide 2-3 numbered choices for the player at the end.';
      case GameCategory.fantasy:
        return 'You are a fantasy-themed RPG game master. Start a fantasy story set in a magical world in English. The player should be an adventurer, wizard, or warrior. Write the story in 2-3 paragraphs and provide 2-3 numbered choices for the player at the end.';
    }
  }

  /// Devam prompt'u oluşturur
  String getContinuePrompt(String userInput, List<String> conversationHistory) {
    final languageService = LanguageService();
    String history = conversationHistory.join('\n\n');
    
    if (languageService.isTurkish) {
      return '''Önceki konuşma geçmişi:
$history

Oyuncunun son seçimi/cevabı: $userInput

Bu seçime/cevaba göre hikayeyi devam ettir. Türkçe olarak 2-3 paragraf yaz ve sonunda oyuncuya yeni 2-3 seçenek sun. Her seçeneği numaralandır. Hikayeyi ilginç ve sürükleyici tut.''';
    } else {
      return '''Previous conversation history:
$history

Player's last choice/response: $userInput

Continue the story based on this choice/response. Write 2-3 paragraphs in English and provide 2-3 new numbered choices for the player at the end. Keep the story interesting and engaging.''';
    }
  }
} 