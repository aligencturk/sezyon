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
        '''Sen profesyonel bir RPG oyunu yöneticisisin. Oyuncu için GİRİŞ aşamasında KISA bir başlangıç hikayesi yaz.

ZORUNLU HİKAYE YAPISI - MUTLAKA TAKİP ET:
Bu hikaye GİRİŞ AŞAMASINDA başlıyor. Sadece giriş aşamasına uygun içerik üret.

GİRİŞ AŞAMASI KURALLARI:
- Dünyayı ve durumu KISA şekilde tanıt
- Karakteri aksiyonun içine at
- Atmosfer kur ve merak uyandır
- Temel çatışmayı ima et
- HENÜZ sonuç verme, sadece durumu betimle
- HENÜZ doruk noktasına çıkma

KISALIK KURALLARI - MUTLAKA UYGULA:
- SADECE 2-3 KISA cümle yaz (maksimum 100 kelime)
- Her cümleyi tamamla, yarıda bırakma
- Öz ve etkili ol
- Gereksiz detaylardan kaçın

YAPMA:
- Uzun paragraflar yazma
- Hikayeyi bitirme
- Ana çatışmayı çözme
- "Hazır mısın?", "Ne yapacaksın?" gibi sorular sorma
- Seçenek sunma

MUTLAKA KISA ve sadece GİRİŞ aşamasına uygun içerik üret!
Dil: Türkçe''';
    String categoryPrompt = '';

    switch (this) {
      case GameCategory.war:
        categoryPrompt = '''Tema: Gerçek Tarihten İlham Alan Savaş Hikayesi.

ZORUNLU KURALLAR:
- Gerçek bir tarihi savaştan ilham al (1. Dünya Savaşı, 2. Dünya Savaşı, Çanakkale, Kurtuluş Savaşı, Vietnam, Kore vb.)
- Tarihi gerçeklere uygun atmosfer ve detaylar kullan
- Gerçek coğrafi yerler ve dönem özellikleri
- Oyuncu bir asker, sivil, doktor, gazeteci veya savaşa tanık olan biri olabilir
- Hikayede isimlendirilmiş karakterler olsun (Komutan Mehmet, Hemşire Anna, Gazeteci Pierre vb.)
- Karakterlerle etkileşim ve diyaloglar olsun
- Tarihi atmosferi koruyarak kurgusal hikaye anlat''';
        break;
      case GameCategory.sciFi:
        categoryPrompt = '''Tema: Bilim Kurgu. 
- Oyuncu, uzak bir gelecekte, bir uzay gemisinde veya yabancı bir gezegende olabilir
- İsimlendirilmiş karakterler olsun (Kaptan Nova, Dr. Zara, Android X-7 vb.)
- Karakterlerle etkileşim ve diyaloglar olsun''';
        break;
      case GameCategory.fantasy:
        categoryPrompt = '''Tema: Fantastik. 
- Oyuncu, ejderhaların, büyücülerin ve krallıkların olduğu bir diyarda bir maceracı olabilir
- İsimlendirilmiş karakterler olsun (Büyücü Eldara, Şövalye Gareth, Ejder Pyrion vb.)
- Karakterlerle etkileşim ve diyaloglar olsun''';
        break;
      case GameCategory.mystery:
        categoryPrompt = '''Tema: Gizem. 
- Oyuncu, 1920'lerin kasvetli bir şehrinde bir dedektif veya gizemli bir olaya tanık olan biri olabilir
- İsimlendirilmiş karakterler olsun (Dedektif Holmes, Bayan Margaret, Şüpheli Charles vb.)
- Karakterlerle etkileşim ve diyaloglar olsun''';
        break;
      case GameCategory.historical:
        categoryPrompt = '''Tema: Gerçek Tarihten İlham Alan Tarihi Hikaye.

ZORUNLU KURALLAR:
- Gerçek bir tarihi dönemden ilham al (Osmanlı İmparatorluğu, Roma İmparatorluğu, Orta Çağ, Rönesans, Sanayi Devrimi vb.)
- Tarihi gerçeklere uygun atmosfer, kıyafetler, teknoloji seviyesi
- Gerçek tarihi şehirler ve yerler (İstanbul, Roma, Paris, Londra vb.)
- Dönemin sosyal yapısı, kültürü ve yaşam tarzını yansıt
- Oyuncu bir tüccar, sanatçı, asker, soylu veya halktan biri olabilir
- Hikayede isimlendirilmiş karakterler olsun (Tüccar Ahmet, Ressam Leonardo, Kont Wilhelm vb.)
- Karakterlerle etkileşim ve diyaloglar olsun
- Tarihi atmosferi koruyarak kurgusal hikaye anlat''';
        break;
      case GameCategory.apocalypse:
        categoryPrompt = '''Tema: Kıyamet Sonrası. 
- Oyuncu, medeniyetin çöktüğü, tehlikelerle dolu bir dünyada hayatta kalmaya çalışan biri olabilir
- İsimlendirilmiş karakterler olsun (Rehber Marcus, Doktor Sarah, Çete Lideri Kane vb.)
- Karakterlerle etkileşim ve diyaloglar olsun''';
        break;
    }
    return '$basePrompt\n$categoryPrompt';
  }

  /// İngilizce başlangıç prompt'u
  String _getEnglishInitialPrompt() {
    final basePrompt =
        '''You are a professional RPG game master. Write a SHORT immersive starting story for the player in INTRODUCTION phase.

MANDATORY STORY STRUCTURE - MUST FOLLOW:
This story starts in INTRODUCTION PHASE. Generate content only appropriate for introduction phase.

INTRODUCTION PHASE RULES:
- Introduce the world and situation BRIEFLY
- Throw character into action
- Set atmosphere and create intrigue
- Hint at basic conflict
- DO NOT give conclusions yet, just describe situation
- DO NOT reach climax yet

BREVITY RULES - MUST APPLY:
- Write ONLY 2-3 SHORT sentences (maximum 100 words)
- Complete each sentence, don't cut off mid-sentence
- Be concise and effective
- Avoid unnecessary details

DON'T:
- Write long paragraphs
- End the story
- Resolve main conflict
- Ask "Are you ready?", "What do you do?" type questions
- Offer choices

MUST generate SHORT content only appropriate for INTRODUCTION phase!
Language: English''';
    String categoryPrompt = '';

    switch (this) {
      case GameCategory.war:
        categoryPrompt = '''Theme: Real History-Inspired War Story.

MANDATORY RULES:
- Draw inspiration from a real historical war (WWI, WWII, Vietnam, Korean War, Civil War, etc.)
- Use historically accurate atmosphere and details
- Real geographical locations and period characteristics
- Player could be a soldier, civilian, doctor, journalist, or war witness
- Include named characters in the story (Commander Smith, Nurse Marie, Journalist Paul, etc.)
- Include character interactions and dialogues
- Tell fictional story while maintaining historical atmosphere''';
        break;
      case GameCategory.sciFi:
        categoryPrompt = '''Theme: Sci-Fi.
- Player could be in a distant future, on a spaceship, or an alien planet
- Include named characters (Captain Nova, Dr. Zara, Android X-7, etc.)
- Include character interactions and dialogues''';
        break;
      case GameCategory.fantasy:
        categoryPrompt = '''Theme: Fantasy.
- Player could be an adventurer in a land of dragons, wizards, and kingdoms
- Include named characters (Wizard Eldara, Knight Gareth, Dragon Pyrion, etc.)
- Include character interactions and dialogues''';
        break;
      case GameCategory.mystery:
        categoryPrompt = '''Theme: Mystery.
- Player could be a detective in a gloomy 1920s city or witness to a mysterious event
- Include named characters (Detective Holmes, Lady Margaret, Suspect Charles, etc.)
- Include character interactions and dialogues''';
        break;
      case GameCategory.historical:
        categoryPrompt = '''Theme: Real History-Inspired Historical Story.

MANDATORY RULES:
- Draw inspiration from a real historical period (Ottoman Empire, Roman Empire, Medieval times, Renaissance, Industrial Revolution, etc.)
- Use historically accurate atmosphere, clothing, technology level
- Real historical cities and places (Istanbul, Rome, Paris, London, etc.)
- Reflect the social structure, culture and lifestyle of the period
- Player could be a merchant, artist, soldier, noble, or commoner
- Include named characters in the story (Merchant Ahmed, Artist Leonardo, Count Wilhelm, etc.)
- Include character interactions and dialogues
- Tell fictional story while maintaining historical atmosphere''';
        break;
      case GameCategory.apocalypse:
        categoryPrompt = '''Theme: Post-Apocalyptic.
- Player could be a survivor in a world full of dangers where civilization has collapsed
- Include named characters (Guide Marcus, Doctor Sarah, Gang Leader Kane, etc.)
- Include character interactions and dialogues''';
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

ZORUNLU HİKAYE AŞAMASI: ${_getPhaseDescription(phase, true)}

MUTLAKA UYULACAK KURALLAR:
${_getPhaseSpecificRules(phase, true)}

KISALIK KURALLARI - MUTLAKA UYGULA:
- SADECE 2-3 KISA cümle yaz (maksimum 150 kelime)
- Her cümleyi tamamla, yarıda bırakma
- Öz ve etkili ol
- Gereksiz detaylardan kaçın

AŞAMA KURALLARI - MUTLAKA TAKİP ET:
- SADECE mevcut aşamaya uygun içerik üret
- Aşama sıralamasını ASLA bozma
- ${phase == StoryPhase.introduction ? 'Henüz sonuç verme, sadece durumu tanıt' : ''}
- ${phase == StoryPhase.development ? 'Henüz doruk noktasına çıkma, sadece geliştir' : ''}
- ${phase == StoryPhase.climax ? 'Ana çatışmayı başlat ama henüz bitirme' : ''}
- ${phase == StoryPhase.conclusion ? 'Artık hikayeyi sonlandırabilirsin' : ''}

GÖREV: Oyuncunun seçtiği eylemi gerçekleştirdiğini varsayarak hikayenin sonucunu KISA şekilde anlat.

YAPMA:
- Uzun paragraflar yazma
- Aşama atlaması
- Erken sonlandırma
- Seçenek sunma
- "Ne yapmak istersin?" sorma

MUTLAKA KISA ve mevcut aşamaya uygun içerik üret!''';
    } else {
      return '''Previous conversation history:
$history

Player's chosen action: "$userInput"

MANDATORY STORY PHASE: ${_getPhaseDescription(phase, false)}

MUST FOLLOW RULES:
${_getPhaseSpecificRules(phase, false)}

BREVITY RULES - MUST APPLY:
- Write ONLY 2-3 SHORT sentences (maximum 150 words)
- Complete each sentence, don't cut off mid-sentence
- Be concise and effective
- Avoid unnecessary details

PHASE RULES - MUST FOLLOW:
- Generate content ONLY appropriate for current phase
- NEVER break phase sequence
- ${phase == StoryPhase.introduction ? 'Do not give conclusions yet, just introduce situation' : ''}
- ${phase == StoryPhase.development ? 'Do not reach climax yet, just develop' : ''}
- ${phase == StoryPhase.climax ? 'Start main conflict but do not finish yet' : ''}
- ${phase == StoryPhase.conclusion ? 'Now you can conclude the story' : ''}

TASK: Assume the player performed their chosen action and describe the story's outcome BRIEFLY.

DON'T:
- Write long paragraphs
- Skip phases
- End early
- Offer choices
- Ask "What do you want to do?"

MUST generate SHORT content appropriate for current phase!''';
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
      case StoryPhase.epilogue:
        return isTurkish
            ? 'EPİLOG - Hikaye sonrası devam'
            : 'EPILOGUE - Post-story continuation';
      case StoryPhase.gameplay:
        // TODO: Handle this case.
        throw UnimplementedError();
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

      case StoryPhase.epilogue:
        return isTurkish
            ? '''KURALLAR:
- Ana hikaye sonrası dönemi anlat
- Karakterin değişimini göster
- Yeni maceralara kapı arala
- Umut verici atmosfer kur'''
            : '''RULES:
- Describe post-main story period
- Show character's transformation
- Open doors to new adventures
- Create hopeful atmosphere''';
      case StoryPhase.gameplay:
        // TODO: Handle this case.
        throw UnimplementedError();
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

  /// Hikaye özeti üretme prompt'u
  String getStorySummaryPrompt(
    List<String> conversationHistory,
    bool isTurkish,
  ) {
    final history = conversationHistory.join('\n\n');

    if (isTurkish) {
      return '''Tamamlanan hikaye:
$history

GÖREV: Bu hikayenin güzel bir özetini yaz (credits benzeri).

KURALLAR:
- Hikayenin ana olaylarını kronolojik sırayla özetle
- Karakterin yaptığı önemli kararları vurgula
- Duygusal ve atmosferik bir dil kullan
- ${_getCategorySummaryStyle(true)}
- 3-4 paragraf olsun
- Hikayenin sonucunu ve etkisini belirt

Örnek format:
"Hikayeniz [kategori] dünyasında başladı...
Verdiğiniz kararlar...
Sonunda...
Bu macera..."

Sadece özeti yaz, başka hiçbir şey ekleme.''';
    } else {
      return '''Completed story:
$history

TASK: Write a beautiful summary of this story (credits-like).

RULES:
- Summarize main events chronologically
- Highlight important decisions made by character
- Use emotional and atmospheric language
- ${_getCategorySummaryStyle(false)}
- 3-4 paragraphs
- State the outcome and impact of the story

Example format:
"Your story began in the [category] world...
The decisions you made...
In the end...
This adventure..."

Only write the summary, add nothing else.''';
    }
  }

  /// Kategori özel özet stili
  String _getCategorySummaryStyle(bool isTurkish) {
    switch (this) {
      case GameCategory.war:
        return isTurkish
            ? 'Savaşın acımasızlığını ve kahramanlığı vurgula'
            : 'Emphasize the brutality and heroism of war';
      case GameCategory.mystery:
        return isTurkish
            ? 'Gizemi çözme sürecini ve ipuçlarını vurgula'
            : 'Emphasize the mystery-solving process and clues';
      case GameCategory.fantasy:
        return isTurkish
            ? 'Büyülü atmosferi ve epik macerayı vurgula'
            : 'Emphasize magical atmosphere and epic adventure';
      case GameCategory.sciFi:
        return isTurkish
            ? 'Teknolojik keşifleri ve gelecek vizyonunu vurgula'
            : 'Emphasize technological discoveries and future vision';
      case GameCategory.historical:
        return isTurkish
            ? 'Tarihi atmosferi ve dönemin özelliklerini vurgula'
            : 'Emphasize historical atmosphere and period characteristics';
      case GameCategory.apocalypse:
        return isTurkish
            ? 'Hayatta kalma mücadelesini ve umut temalarını vurgula'
            : 'Emphasize survival struggle and themes of hope';
    }
  }

  /// Epilog prompt'u oluşturur
  String getEpiloguePrompt(List<String> conversationHistory, bool isTurkish) {
    if (isTurkish) {
      return '''Tamamlanan hikaye:
${conversationHistory.join('\n\n')}

GÖREV: Bu hikayenin epilog aşamasını başlat.

HİKAYE SONRASI TEMA: ${_getEpilogueTheme(true)}

KURALLAR:
- Ana hikaye bittikten sonraki dönemi anlat
- ${_getEpilogueSpecificRules(true)}
- Karakterin yeni durumunu ve çevresini betimle
- Yeni maceralara kapı aralayacak atmosfer kur
- 2-3 cümle ile başlangıç yap

Sadece epilog başlangıcını yaz, seçenek sunma.''';
    } else {
      return '''Completed story:
${conversationHistory.join('\n\n')}

TASK: Start the epilogue phase of this story.

POST-STORY THEME: ${_getEpilogueTheme(false)}

RULES:
- Describe the period after the main story ended
- ${_getEpilogueSpecificRules(false)}
- Describe character's new situation and environment
- Create atmosphere that opens doors to new adventures
- Start with 2-3 sentences

Only write the epilogue beginning, don't offer choices.''';
    }
  }

  /// Epilog teması
  String _getEpilogueTheme(bool isTurkish) {
    switch (this) {
      case GameCategory.war:
        return isTurkish
            ? 'Savaş sonrası psikoloji ve ülkenin yeniden inşası'
            : 'Post-war psychology and country reconstruction';
      case GameCategory.mystery:
        return isTurkish
            ? 'Gizem çözüldükten sonra yeni sırlar ve sonuçlar'
            : 'New secrets and consequences after mystery solved';
      case GameCategory.fantasy:
        return isTurkish
            ? 'Büyülü görev sonrası yeni güçler ve sorumluluklar'
            : 'New powers and responsibilities after magical quest';
      case GameCategory.sciFi:
        return isTurkish
            ? 'Görev sonrası teknolojik gelişmeler ve keşifler'
            : 'Technological developments and discoveries after mission';
      case GameCategory.historical:
        return isTurkish
            ? 'Tarihi olay sonrası dönemin değişimi ve etkileri'
            : 'Period changes and effects after historical event';
      case GameCategory.apocalypse:
        return isTurkish
            ? 'Hayatta kaldıktan sonra yeni toplum kurma'
            : 'Building new society after survival';
    }
  }

  /// Epilog özel kuralları
  String _getEpilogueSpecificRules(bool isTurkish) {
    switch (this) {
      case GameCategory.war:
        return isTurkish
            ? '''Savaş travmasını, yeniden inşa sürecini ve barış zamanını anlat
- Gerçek tarihi savaş sonrası dönemden ilham al
- Savaş arkadaşları, komutanlar, siviller gibi isimli karakterlerle etkileşim
- Savaş sonrası psikolojik durumu ve toplumsal değişimleri betimle'''
            : '''Describe war trauma, reconstruction process and peacetime
- Draw inspiration from real post-war historical periods
- Interactions with named characters like war comrades, commanders, civilians
- Describe post-war psychological state and social changes''';
      case GameCategory.mystery:
        return isTurkish
            ? '''Çözülen gizemin etkilerini ve ortaya çıkan yeni ipuçlarını anlat
- Dedektif, şüpheliler, tanıklar gibi isimli karakterlerle etkileşim
- Gizem çözümünün toplumsal etkilerini göster'''
            : '''Describe effects of solved mystery and emerging new clues
- Interactions with named characters like detectives, suspects, witnesses
- Show social impact of mystery resolution''';
      case GameCategory.fantasy:
        return isTurkish
            ? '''Kazanılan güçlerin sorumluluğunu ve yeni maceraları anlat
- Büyücüler, şövalyeler, kraliyet üyeleri gibi isimli karakterlerle etkileşim
- Büyülü dünyanın değişimini ve yeni sorumlulukları betimle'''
            : '''Describe responsibility of gained powers and new adventures
- Interactions with named characters like wizards, knights, royalty
- Describe magical world changes and new responsibilities''';
      case GameCategory.sciFi:
        return isTurkish
            ? '''Teknolojik ilerlemelerin etkilerini ve yeni keşifleri anlat
- Bilim insanları, mühendisler, uzay mürettebatı gibi isimli karakterlerle etkileşim
- Teknolojik gelişmelerin toplumsal etkilerini göster'''
            : '''Describe effects of technological advances and new discoveries
- Interactions with named characters like scientists, engineers, space crew
- Show social impact of technological developments''';
      case GameCategory.historical:
        return isTurkish
            ? '''Tarihi olayın uzun vadeli etkilerini ve değişimleri anlat
- Gerçek tarihi dönem sonrası değişimlerden ilham al
- Tüccarlar, sanatçılar, soylu aileler gibi isimli karakterlerle etkileşim
- Dönemin sosyal, ekonomik ve kültürel değişimlerini betimle'''
            : '''Describe long-term effects and changes of historical event
- Draw inspiration from real historical period changes
- Interactions with named characters like merchants, artists, noble families
- Describe social, economic and cultural changes of the period''';
      case GameCategory.apocalypse:
        return isTurkish
            ? '''Yeni toplum kurma sürecini ve umut dolu geleceği anlat
- Hayatta kalanlar, liderler, uzmanlar gibi isimli karakterlerle etkileşim
- Yeni toplumsal düzenin kurulması ve umut temalarını işle'''
            : '''Describe new society building process and hopeful future
- Interactions with named characters like survivors, leaders, specialists
- Process establishment of new social order and themes of hope''';
    }
  }
}
