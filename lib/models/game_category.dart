import '../services/language_service.dart';
import 'message.dart';

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

  /// Hikaye aşamasını belirler
  StoryPhase determineStoryPhase(List<String> conversationHistory) {
    final messageCount = conversationHistory.length;

    // Her kategori için farklı aşama geçiş noktaları - daha uzun hikayeler
    switch (this) {
      case GameCategory.war:
        if (messageCount <= 8)
          return StoryPhase.introduction; // Savaş öncesi durum, hazırlık
        if (messageCount <= 16)
          return StoryPhase.development; // Savaşa sürüklenme süreci
        if (messageCount <= 24)
          return StoryPhase.climax; // Savaş anı, kritik çatışmalar
        return StoryPhase.conclusion; // Savaş sonrası, sonuçlar

      case GameCategory.mystery:
        if (messageCount <= 10)
          return StoryPhase.introduction; // Gizem ortaya çıkıyor
        if (messageCount <= 20)
          return StoryPhase.development; // İpuçları toplama, araştırma
        if (messageCount <= 28)
          return StoryPhase.climax; // Ana ipucu bulma, çözüme yaklaşma
        return StoryPhase.conclusion; // Gizemi çözme

      case GameCategory.fantasy:
        if (messageCount <= 8)
          return StoryPhase.introduction; // Büyülü dünyaya giriş
        if (messageCount <= 18)
          return StoryPhase
              .development; // Macera gelişiyor, zorluklarla karşılaşma
        if (messageCount <= 26)
          return StoryPhase.climax; // Ana boss/büyük tehlike
        return StoryPhase.conclusion; // Görevi tamamlama

      case GameCategory.sciFi:
        if (messageCount <= 8)
          return StoryPhase.introduction; // Uzay/gelecek dünyasına giriş
        if (messageCount <= 18)
          return StoryPhase.development; // Görev gelişiyor, teknolojik sorunlar
        if (messageCount <= 26)
          return StoryPhase.climax; // Ana görev, kritik kararlar
        return StoryPhase.conclusion; // Görevi bitirme

      case GameCategory.historical:
        if (messageCount <= 10)
          return StoryPhase.introduction; // Tarihi döneme giriş
        if (messageCount <= 20)
          return StoryPhase.development; // Tarihi olayların gelişimi
        if (messageCount <= 28)
          return StoryPhase.climax; // Tarihi anın yaşanması
        return StoryPhase.conclusion; // Tarihi sonuçlar

      case GameCategory.apocalypse:
        if (messageCount <= 8)
          return StoryPhase.introduction; // Kıyamet sonrası dünyaya giriş
        if (messageCount <= 18)
          return StoryPhase.development; // Hayatta kalma mücadelesi
        if (messageCount <= 26) return StoryPhase.climax; // En büyük tehlike
        return StoryPhase.conclusion; // Güvenli bölgeye ulaşma
    }
  }

  /// Hikayenin sonlanması gerekip gerekmediğini kontrol eder
  bool shouldEndStory(List<String> conversationHistory, String lastResponse) {
    final phase = determineStoryPhase(conversationHistory);

    // Sadece climax aşamasından sonra sonlanabilir
    if (phase != StoryPhase.conclusion) return false;

    // Son yanıtta sonlandırma ipuçları var mı kontrol et
    final lowerResponse = lastResponse.toLowerCase();

    // Genel sonlandırma kelimeleri
    final endKeywords = [
      'son',
      'bitti',
      'tamamlandı',
      'sona erdi',
      'bitirdi',
      'end',
      'finished',
      'completed',
      'concluded',
      'over',
    ];

    // Kategori özel sonlandırma kelimeleri
    final categoryEndKeywords = _getCategoryEndKeywords();

    return endKeywords.any((keyword) => lowerResponse.contains(keyword)) ||
        categoryEndKeywords.any((keyword) => lowerResponse.contains(keyword));
  }

  /// Kategori özel sonlandırma anahtar kelimeleri
  List<String> _getCategoryEndKeywords() {
    switch (this) {
      case GameCategory.war:
        return [
          'savaş bitti',
          'zafer',
          'yenilgi',
          'barış',
          'war ended',
          'victory',
          'defeat',
          'peace',
        ];
      case GameCategory.mystery:
        return [
          'gizem çözüldü',
          'suçlu bulundu',
          'mystery solved',
          'culprit found',
          'case closed',
        ];
      case GameCategory.fantasy:
        return [
          'ejder yenildi',
          'büyü bozuldu',
          'krallık kurtuldu',
          'dragon defeated',
          'spell broken',
          'kingdom saved',
        ];
      case GameCategory.sciFi:
        return [
          'görev tamamlandı',
          'gezegen kurtuldu',
          'mission completed',
          'planet saved',
          'ship arrived',
        ];
      case GameCategory.historical:
        return [
          'tarih yazıldı',
          'kader belirlendi',
          'history written',
          'fate decided',
          'legacy established',
        ];
      case GameCategory.apocalypse:
        return [
          'hayatta kaldı',
          'güvenli bölge',
          'survived',
          'safe zone',
          'sanctuary found',
        ];
    }
  }

  /// Devam prompt'u oluşturur
  String getContinuePrompt(String userInput, List<String> conversationHistory) {
    final languageService = LanguageService();
    final phase = determineStoryPhase(conversationHistory);
    String history = conversationHistory.join('\n\n');

    if (languageService.isTurkish) {
      return '''Önceki konuşma geçmişi:
$history

Oyuncunun seçtiği eylem: "$userInput"

HİKAYE AŞAMASI: ${_getPhaseDescription(phase, true)}

GÖREV: Oyuncunun seçtiği eylemi gerçekleştirdiğini varsayarak hikayenin sonucunu anlat.

${_getPhaseSpecificRules(phase, true)}

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

STORY PHASE: ${_getPhaseDescription(phase, false)}

TASK: Assume the player performed their chosen action and describe the story's outcome.

${_getPhaseSpecificRules(phase, false)}

DON'T:
- Offer choices
- Ask "What do you want to do?"
- Give lists
- Give advice

Only write the story, add nothing else.''';
    }
  }

  /// Aşama açıklaması
  String _getPhaseDescription(StoryPhase phase, bool isTurkish) {
    switch (phase) {
      case StoryPhase.introduction:
        return isTurkish
            ? 'GİRİŞ - Durumu tanıt ve atmosfer kur'
            : 'INTRODUCTION - Introduce situation and set atmosphere';
      case StoryPhase.development:
        return isTurkish
            ? 'GELİŞME - Olayları geliştir ve gerilimi artır'
            : 'DEVELOPMENT - Develop events and increase tension';
      case StoryPhase.climax:
        return isTurkish
            ? 'DORUK - Ana çatışma ve kritik kararlar'
            : 'CLIMAX - Main conflict and critical decisions';
      case StoryPhase.conclusion:
        return isTurkish
            ? 'SONUÇ - Hikayeyi sonlandırmaya hazırlan'
            : 'CONCLUSION - Prepare to conclude the story';
    }
  }

  /// Aşamaya özel kurallar
  String _getPhaseSpecificRules(StoryPhase phase, bool isTurkish) {
    switch (phase) {
      case StoryPhase.introduction:
        return isTurkish
            ? '''KURALLAR:
- Dünyayı ve durumu tanıt
- Karakteri aksiyonun içine at
- Merak uyandıracak detaylar ver
- Hikayeyi yavaş yavaş geliştir'''
            : '''RULES:
- Introduce the world and situation
- Throw character into action
- Give intriguing details
- Gradually develop the story''';

      case StoryPhase.development:
        return isTurkish
            ? '''KURALLAR:
- Olayları karmaşıklaştır
- Yeni karakterler/tehlikeler tanıt
- Gerilimi sürekli artır
- Ana hedefe doğru ilerle'''
            : '''RULES:
- Complicate events
- Introduce new characters/dangers
- Continuously increase tension
- Progress toward main goal''';

      case StoryPhase.climax:
        return isTurkish
            ? '''KURALLAR:
- Ana çatışmayı başlat
- Kritik kararlar aldır
- Yoğun aksiyon ve drama
- Sonuca doğru hızlan'''
            : '''RULES:
- Start main conflict
- Force critical decisions
- Intense action and drama
- Accelerate toward conclusion''';

      case StoryPhase.conclusion:
        return isTurkish
            ? '''KURALLAR:
- Hikayeyi sonlandırmaya hazırlan
- Ana hedefi gerçekleştir (${_getCategoryGoal(true)})
- Tatmin edici bir sonuç ver
- Eğer uygunsa hikayeyi bitir'''
            : '''RULES:
- Prepare to conclude story
- Achieve main goal (${_getCategoryGoal(false)})
- Provide satisfying conclusion
- End story if appropriate''';
    }
  }

  /// Kategori hedefini döndürür
  String _getCategoryGoal(bool isTurkish) {
    switch (this) {
      case GameCategory.war:
        return isTurkish
            ? 'savaşa katılım ve sonuç'
            : 'war participation and outcome';
      case GameCategory.mystery:
        return isTurkish ? 'gizemi çözme' : 'solving the mystery';
      case GameCategory.fantasy:
        return isTurkish
            ? 'büyülü görevi tamamlama'
            : 'completing magical quest';
      case GameCategory.sciFi:
        return isTurkish
            ? 'bilimkurgu görevini bitirme'
            : 'finishing sci-fi mission';
      case GameCategory.historical:
        return isTurkish
            ? 'tarihi olayı yaşama'
            : 'experiencing historical event';
      case GameCategory.apocalypse:
        return isTurkish ? 'hayatta kalma' : 'survival';
    }
  }
}
