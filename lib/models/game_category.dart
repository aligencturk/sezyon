import '../services/language_service.dart';

/// Oyun kategorileri enum'u
enum GameCategory {
  war('war'),
  sciFi('sciFi'),
  fantasy('fantasy'),
  mystery('mystery'),
  historical('historical'),
  apocalypse('apocalypse');

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
    final basePrompt =
        'Sen bir RPG oyunu yöneticisisin. Oyuncu için kısa, etkileyici ve merak uyandıran bir başlangıç hikayesi yaz. Hikaye tek bir kısa paragraftan oluşmalı ve oyuncuya ne yapabileceğine dair bir soruyla bitmeli. Dil Türkçe olmalı.';
    String categoryPrompt = '';

    switch (this) {
      case GameCategory.war:
        categoryPrompt =
            'Tema: Savaş. Oyuncu, savaşın ortasında kalmış bir asker veya sivil olabilir.';
        break;
      case GameCategory.sciFi:
        categoryPrompt =
            'Tema: Bilim Kurgu. Oyuncu, uzak bir gelecekte, bir uzay gemisinde veya yabancı bir gezegende olabilir.';
        break;
      case GameCategory.fantasy:
        categoryPrompt =
            'Tema: Fantastik. Oyuncu, ejderhaların, büyücülerin ve krallıkların olduğu bir diyarda bir maceracı olabilir.';
        break;
      case GameCategory.mystery:
        categoryPrompt =
            'Tema: Gizem. Oyuncu, 1920\'lerin kasvetli bir şehrinde bir dedektif veya gizemli bir olaya tanık olan biri olabilir.';
        break;
      case GameCategory.historical:
        categoryPrompt =
            'Tema: Tarihi. Oyuncu, Antik Roma, Orta Çağ Japonya\'sı veya Vahşi Batı gibi bir dönemde yaşayan bir karakter olabilir.';
        break;
      case GameCategory.apocalypse:
        categoryPrompt =
            'Tema: Kıyamet Sonrası. Oyuncu, medeniyetin çöktüğü, tehlikelerle dolu bir dünyada hayatta kalmaya çalışan biri olabilir.';
        break;
    }
    return '$basePrompt\n$categoryPrompt';
  }

  /// İngilizce başlangıç prompt'u
  String _getEnglishInitialPrompt() {
    final basePrompt =
        'You are an RPG game master. Write a short, immersive, and intriguing starting story for the player. The story should be a single short paragraph and end with a question to the player about what they would like to do. The language must be English.';
    String categoryPrompt = '';

    switch (this) {
      case GameCategory.war:
        categoryPrompt =
            'Theme: War. The player could be a soldier or a civilian caught in the middle of a war.';
        break;
      case GameCategory.sciFi:
        categoryPrompt =
            'Theme: Sci-Fi. The player could be in a distant future, on a spaceship, or an alien planet.';
        break;
      case GameCategory.fantasy:
        categoryPrompt =
            'Theme: Fantasy. The player could be an adventurer in a land of dragons, wizards, and kingdoms.';
        break;
      case GameCategory.mystery:
        categoryPrompt =
            'Theme: Mystery. The player could be a detective in a gloomy 1920s city or a witness to a mysterious event.';
        break;
      case GameCategory.historical:
        categoryPrompt =
            'Theme: Historical. The player could be a character living in a period like Ancient Rome, Medieval Japan, or the Wild West.';
        break;
      case GameCategory.apocalypse:
        categoryPrompt =
            'Theme: Post-Apocalyptic. The player could be a survivor in a world full of dangers where civilization has collapsed.';
        break;
    }
    return '$basePrompt\n$categoryPrompt';
  }

  /// Kategori için açıklama metni oluşturur
  String getDescription(String languageCode) {
    bool isTurkish = languageCode == 'tr';
    switch (this) {
      case GameCategory.war:
        return isTurkish
            ? 'Savaşın acımasız gerçekleriyle yüzleş. Vereceğin kararlar cephenin kaderini belirleyecek.'
            : 'Face the brutal realities of war. Your decisions will determine the fate of the front line.';
      case GameCategory.sciFi:
        return isTurkish
            ? 'Yıldızların ötesinde, bilinmeyen tehlikeler ve kadim sırlar seni bekliyor.'
            : 'Beyond the stars, unknown dangers and ancient secrets await you.';
      case GameCategory.fantasy:
        return isTurkish
            ? 'Büyünün ve çeliğin konuştuğu topraklarda efsaneni yaz. Ejderhalar gökyüzünde süzülüyor.'
            : 'Write your legend in lands where magic and steel speak. Dragons soar in the sky.';
      case GameCategory.mystery:
        return isTurkish
            ? 'Her köşesi sisle kaplı bu şehirde hiçbir şey göründüğü gibi değil. İpuçlarını takip et.'
            : 'In this fog-covered city, nothing is as it seems. Follow the clues.';
      case GameCategory.historical:
        return isTurkish
            ? 'Tarihin tozlu sayfalarında bir yolculuğa çık. Geçmişi yeniden şekillendirmek senin elinde.'
            : 'Embark on a journey through the dusty pages of history. It is in your hands to reshape the past.';
      case GameCategory.apocalypse:
        return isTurkish
            ? 'Yıkılmış bir dünyanın enkazında hayatta kalmaya çalış. Tehlike her an, her yerde.'
            : 'Try to survive in the wreckage of a ruined world. Danger is anytime, anywhere.';
    }
  }

  /// Devam prompt'u oluşturur
  String getContinuePrompt(String userInput, List<String> conversationHistory) {
    final languageService = LanguageService();
    String history = conversationHistory.join('\n\n');
    
    if (languageService.isTurkish) {
      return '''Önceki konuşma geçmişi:
$history

Oyuncunun son yanıtı: "$userInput"
Oyuncunun seçtiği eylemi gerçekleştirdiğini varsayarak hikayeyi devam ettir. Oyuncu ne yapmak istediğini söyledi, sen de o eylemin sonucunu anlat. Maksimum 2-3cümle yaz. Sonu açık uçlu olsun ve oyuncuya ne yapacağını sor. Dil Türkçe olmalı. 

ÖNEMLİ: Oyuncuya seçenek sunma, seçenek listesi verme, şunları yapabilirsin" gibi ifadeler kullanma. Oyuncunun eylemini gerçekleştirdiğini kabul et ve sonucunu anlat. Çok kısa tut.
''';
    } else {
      return '''Previous conversation history:
$history

Player's last response: "$userInput"

Assume the player has performed the action they chose and continue the story accordingly. The player told you what they want to do, now describe the result of that action. Write maximum 2-3entences. Keep the end open-ended and ask the player what they do next. The language must be English. 

IMPORTANT: Do not offer choices to the player, do not list options, do not say "you can do this or that". Assume the player's action was completed and describe the result. Keep it very short.
''';
    }
  }
} 