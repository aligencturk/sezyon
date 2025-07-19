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
        '''Sen profesyonel bir RPG oyunu yöneticisisin. Oyuncu için etkileyici bir başlangıç hikayesi yaz.

KURALLAR:
- Kısa ama atmosferik bir paragraf yaz (3-4 cümle)
- Oyuncuyu hemen aksiyonun içine at
- Gerilim ve merak uyandır
- Hikayeyi açık uçlu bitir ama soru sorma
- "Hazır mısın?", "Ne yapacaksın?" gibi sorular kullanma
- Sadece durumu betimle ve bekle

Dil: Türkçe''';
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
        '''You are a professional RPG game master. Write an immersive starting story for the player.

RULES:
- Write a short but atmospheric paragraph (3-4 sentences)
- Throw the player directly into the action
- Create tension and intrigue
- End the story open-ended but don't ask questions
- Don't use "Are you ready?", "What do you do?" type questions
- Just describe the situation and wait

Language: English''';
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

Oyuncunun seçtiği eylem: "$userInput"

GÖREV: Oyuncunun seçtiği eylemi gerçekleştirdiğini varsayarak hikayenin sonucunu anlat.

KURALLAR:
- Sadece hikayeyi devam ettir (2-3 cümle)
- Oyuncunun eyleminin sonucunu detaylı betimle
- Atmosferi ve duyguları güçlü şekilde anlat
- Hikayenin akışını sürdür

YAPMA:
- Seçenek sunma
- "Ne yapmak istersin?" sorma
- Liste verme
- Tavsiye verme

Sadece hikayeyi yaz, başka hiçbir şey ekleme.''';
    } else {
      return '''Previous conversation history:
$history

Player's chosen action: "$userInput"

TASK: Assume the player performed their chosen action and describe the story's outcome.

RULES:
- Only continue the story (2-3 sentences)
- Describe the result of the player's action in detail
- Strongly portray atmosphere and emotions
- Maintain the story flow

DON'T:
- Offer choices
- Ask "What do you want to do?"
- Give lists
- Give advice

Only write the story, add nothing else.''';
    }
  }
}
