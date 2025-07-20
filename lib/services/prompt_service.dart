import '../models/game_category.dart';
import 'language_service.dart';

/// Hikaye aşamaları
enum StoryPhase { introduction, development, climax, conclusion }

/// Sezyon oyunu için GPT-4.1-nano prompt şablonlarını yöneten servis
class PromptService {
  final LanguageService _languageService = LanguageService();

  /// Giriş sahnesi için prompt oluşturur
  String generateIntroductionPrompt({
    required GameCategory category,
    required String characterName,
  }) {
    final isTurkish = _languageService.isTurkish;

    if (isTurkish) {
      return _buildTurkishIntroductionPrompt(category, characterName);
    } else {
      return _buildEnglishIntroductionPrompt(category, characterName);
    }
  }

  /// Devam sahnesi için prompt oluşturur
  String generateContinuePrompt({
    required GameCategory category,
    required String characterName,
    required List<String> history,
    required String userInput,
    required int turnCount,
  }) {
    final isTurkish = _languageService.isTurkish;
    final currentPhase = _determineStoryPhase(turnCount);

    if (isTurkish) {
      return _buildTurkishContinuePrompt(
        category,
        characterName,
        history,
        userInput,
        turnCount,
        currentPhase,
      );
    } else {
      return _buildEnglishContinuePrompt(
        category,
        characterName,
        history,
        userInput,
        turnCount,
        currentPhase,
      );
    }
  }

  /// Final sahnesi için prompt oluşturur
  String generateFinalPrompt({
    required GameCategory category,
    required String characterName,
    required List<String> history,
    required String userInput,
    required int turnCount,
  }) {
    final isTurkish = _languageService.isTurkish;

    if (isTurkish) {
      return _buildTurkishFinalPrompt(
        category,
        characterName,
        history,
        userInput,
      );
    } else {
      return _buildEnglishFinalPrompt(
        category,
        characterName,
        history,
        userInput,
      );
    }
  }

  /// Hikaye özeti için prompt oluşturur
  String generateSummaryPrompt({
    required GameCategory category,
    required String characterName,
    required List<String> history,
  }) {
    final isTurkish = _languageService.isTurkish;

    if (isTurkish) {
      return _buildTurkishSummaryPrompt(category, characterName, history);
    } else {
      return _buildEnglishSummaryPrompt(category, characterName, history);
    }
  }

  /// Tur sayısına göre hikaye aşamasını belirler
  StoryPhase _determineStoryPhase(int turnCount) {
    if (turnCount <= 4) return StoryPhase.introduction;
    if (turnCount <= 10) return StoryPhase.development;
    if (turnCount <= 14) return StoryPhase.climax;
    return StoryPhase.conclusion;
  }

  /// Türkçe giriş prompt'u oluşturur
  String _buildTurkishIntroductionPrompt(
    GameCategory category,
    String characterName,
  ) {
    final categoryContext = _getTurkishCategoryContext(category);

    return '''Sen Sezyon adlı interaktif hikaye oyununun anlatıcısısın. Görevin kullanıcının yazdığı ifadeleri anlamlandırarak hikayeyi doğal ve yaratıcı şekilde sürdürmek.

SEZYON'UN TEMEL KURALLARI - MUTLAKA UYGULA:
- Kullanıcı hikayeyi seçimlerle değil, kendi yazdığı ifadelerle yönlendirir
- Sen bu ifadeleri anlamlandırır ve bağlamı takip ederek hikayeyi sürdürürsün
- Seçenek (A, B, C, D) ASLA sunma - Bu sistem tamamen kaldırılmıştır
- Sahne sonunda yönlendirme değil, SEZDIRME yap
- "Ne yapacaksın?" tarzı sorular sade ve tek cümlelik olur, her sahnede SORULMAZ
- Gerektiğinde hiç soru sorma, sadece atmosferi kur

KARAKTER BİLGİSİ:
- Karakter adı: $characterName
- Karakterin adını hikayede kullan ve kişisel hitaplar yap

HİKAYE AŞAMASI: GİRİŞ
- Dünyayı ve durumu tanıt
- Karakteri aksiyonun içine at
- Atmosfer kur ve merak uyandır
- İsimlendirilmiş karakterler tanıt
- Temel çatışmayı ima et

KATEGORİ: ${category.displayName}
$categoryContext

İSİMLENDİRME ZORUNLULUĞU:
- Yukarıdaki kategori kurallarında belirtilen isimlendirme kurallarını MUTLAKA takip et
- Tarihi kategorilerde dönemine uygun isimler kullan (Osmanlı için Türkçe, Roma için Latince vb.)
- Her karakterin ismi o kategorinin atmosferine uygun olmalı
- Rastgele veya uyumsuz isimler kullanma

YAZIM KURALLARI:
- TAM OLARAK 2 paragraf yaz
- Her paragraf 3-4 cümle olsun
- Kategoriye uygun anlatım tarzı kullan:
  * Fantastik: Epik ve büyülü dil
  * Bilim Kurgu: Teknik ve gelecekçi terimler
  * Gizem: Yoğun ve sessiz atmosfer
  * Savaş: Gerçekçi ve duygusal
  * Tarihi: Dönemine uygun dil
  * Kıyamet: Kasvetli ama umutlu
- Karakterin adını kullan ve kişisel hitaplar yap
- İsimli karakterlerle etkileşim kur
- Her cümleyi tamamla
- Detaylı ve zengin anlatım

YAPMA:
- Seçenek sunma
- Uzun anlatımlar
- Hikayeyi bitirme
- Aşama atlaması

Şimdi $characterName için ${category.displayName} kategorisinde hikayeyi başlat.''';
  }

  /// İngilizce giriş prompt'u oluşturur
  String _buildEnglishIntroductionPrompt(
    GameCategory category,
    String characterName,
  ) {
    final categoryContext = _getEnglishCategoryContext(category);

    return '''You are the narrator of Sezyon, an interactive story game. Your task is to understand user's written expressions and continue the story naturally and creatively.

SEZYON'S CORE RULES - MUST APPLY:
- User directs the story not with choices, but with their own written expressions
- You understand these expressions and continue the story by following context
- NEVER offer choices (A, B, C, D) - This system is completely removed
- At scene end, use SUGGESTION not DIRECTION
- "What do you do?" type questions should be simple and single sentence, NOT asked in every scene
- When needed, don't ask questions at all, just set the atmosphere

CHARACTER INFO:
- Character name: $characterName
- Use character's name in story and make personal addresses

STORY PHASE: INTRODUCTION
- Introduce world and situation
- Throw character into action
- Set atmosphere and create intrigue
- Introduce named characters
- Hint at basic conflict

CATEGORY: ${category.displayName}
$categoryContext

NAMING REQUIREMENT:
- MUST follow the naming rules specified in the category rules above
- Use period-appropriate names for historical categories (Turkish for Ottoman, Latin for Roman etc.)
- Every character's name must fit the category's atmosphere
- Don't use random or inappropriate names

WRITING RULES:
- EXACTLY 2 paragraphs
- Each paragraph should be 3-4 sentences
- Use category-appropriate narrative style:
  * Fantasy: Epic and magical language
  * Sci-Fi: Technical and futuristic terms
  * Mystery: Intense and quiet atmosphere
  * War: Realistic and emotional
  * Historical: Period-appropriate language
  * Apocalypse: Grim but hopeful
- Use character's name and make personal addresses
- Create interactions with named characters
- Complete every sentence
- Detailed and rich narrative

DON'T:
- Offer choices
- Long narratives
- End the story
- Skip phases

Now start the story for $characterName in ${category.displayName} category.''';
  }

  /// Türkçe devam prompt'u oluşturur
  String _buildTurkishContinuePrompt(
    GameCategory category,
    String characterName,
    List<String> history,
    String userInput,
    int turnCount,
    StoryPhase currentPhase,
  ) {
    final historyText = history.join('\n\n');
    final phaseDescription = _getTurkishPhaseDescription(currentPhase);
    final phaseRules = _getTurkishPhaseRules(currentPhase);
    final characterContext = _extractCharacterContext(history);
    final locationContext = _extractLocationContext(history);

    return '''Sen Sezyon hikaye anlatıcısısın. MUTLAKA hikaye tutarlılığını koru ve önceki olayları takip et.

KARAKTER: $characterName
TUR SAYISI: $turnCount/15
MEVCUT AŞAMA: $phaseDescription

ÖNCEKİ HİKAYE ÖZET:
$historyText

KULLANICI İFADESİ: "$userInput"

TUTARLILIK KURALLARI - MUTLAKA UYGULA:
- Önceki hikayede bahsedilen TÜM karakterleri hatırla ve tutarlı davran
- Karakterlerin önceki konuşmaları ve davranışlarını takip et
- Mekan değişikliklerini mantıklı şekilde açıkla
- Önceki olayların sonuçlarını göz önünde bulundur
- Karakterlerin motivasyonlarını ve kişiliklerini koru
- Zaman akışını tutarlı tut

KARAKTER TAKIP SİSTEMİ:
$characterContext

MEKAN TAKIP SİSTEMİ:
$locationContext

AŞAMA KURALLARI:
$phaseRules

SEZYON'UN TEMEL KURALLARI - MUTLAKA UYGULA:
- Kullanıcının ifadesini anlamlandır ve TUTARLI sonucunu anlat
- $characterName'in adını kullan ve kişisel hitaplar yap ("$characterName, senin gibi biri için..." tarzında)
- Önceki karakterlerle TUTARLI etkileşim kur
- Bağlamı MUTLAKA takip et, hiçbir detayı unutma
- Eylemler mantıklı ve tutarlı sonuç doğursun
- Karakterlerin önceki sözlerini ve davranışlarını hatırla
- Oyuncunun yazı tarzına uyum sağla: Detaylı yazıyorsa detaylı anlat, kısa yazıyorsa özlü tepki ver
- Sahne sonunda SEZDIRME yap, yönlendirme yapma

YAZIM KURALLARI:
- 3-4 paragraf yaz (daha detaylı anlatım için)
- Her paragraf 3-5 cümle olsun
- Atmosferik ve akıcı dil
- Her cümleyi tamamla
- Karakterin adını hikayede kullan
- Çok detaylı ve zengin anlatım
- Önceki olaylarla bağlantı kur

YAPMA:
- Seçenek sunma (A, B, C, D)
- Önceki olayları unutma veya çelişme
- Karakterleri farklı yerlerde gösterme (tutarsızlık)
- Aşama sıralamasını bozma
- Hikayeyi erken bitirme
- Karakterlerin kişiliklerini değiştirme

MUTLAKA önceki hikayeyle TUTARLI şekilde $characterName'in "$userInput" ifadesinin sonucunu anlat.''';
  }

  /// İngilizce devam prompt'u oluşturur
  String _buildEnglishContinuePrompt(
    GameCategory category,
    String characterName,
    List<String> history,
    String userInput,
    int turnCount,
    StoryPhase currentPhase,
  ) {
    final historyText = history.join('\n\n');
    final phaseDescription = _getEnglishPhaseDescription(currentPhase);
    final phaseRules = _getEnglishPhaseRules(currentPhase);
    final characterContext = _extractCharacterContext(history);
    final locationContext = _extractLocationContext(history);

    return '''You are Sezyon story narrator. MUST maintain story consistency and track previous events.

CHARACTER: $characterName
TURN COUNT: $turnCount/15
CURRENT PHASE: $phaseDescription

PREVIOUS STORY SUMMARY:
$historyText

USER EXPRESSION: "$userInput"

CONSISTENCY RULES - MUST APPLY:
- Remember ALL characters mentioned in previous story and act consistently
- Track characters' previous conversations and behaviors
- Explain location changes logically
- Consider consequences of previous events
- Maintain characters' motivations and personalities
- Keep time flow consistent

CHARACTER TRACKING SYSTEM:
$characterContext

LOCATION TRACKING SYSTEM:
$locationContext

PHASE RULES:
$phaseRules

SEZYON'S CORE RULES - MUST APPLY:
- Understand user's expression and describe CONSISTENT outcome
- Use $characterName's name and make personal addresses ("$characterName, someone like you..." style)
- Create CONSISTENT interactions with previous characters
- MUST follow context, never forget any details
- Actions should have logical and consistent consequences
- Remember characters' previous words and behaviors
- Adapt to player's writing style: If detailed, write detailed; if brief, give concise responses
- At scene end, use SUGGESTION not DIRECTION

WRITING RULES:
- Write 3-4 paragraphs (for more detailed narrative)
- Each paragraph should be 3-5 sentences
- Atmospheric and flowing language
- Complete every sentence
- Use character's name in story
- Very detailed and rich narrative
- Connect with previous events

DON'T:
- Offer choices (A, B, C, D)
- Forget or contradict previous events
- Show characters in different places (inconsistency)
- Break phase sequence
- End story early
- Change characters' personalities

MUST describe the outcome of $characterName's "$userInput" expression CONSISTENTLY with previous story.''';
  }

  /// Türkçe final prompt'u oluşturur
  String _buildTurkishFinalPrompt(
    GameCategory category,
    String characterName,
    List<String> history,
    String userInput,
  ) {
    final historyText = history.join('\n\n');

    return '''Sen Sezyon hikaye anlatıcısısın. Hikayeyi tatmin edici şekilde sonlandır.

KARAKTER: $characterName
DURUM: HİKAYE FİNALİ (15. tur veya sonlandırma iması)

ÖNCEKİ HİKAYE:
$historyText

SON İFADE: "$userInput"

FİNAL KURALLARI:
- Ana çatışmayı çöz
- $characterName'in kaderini belirle
- Tatmin edici sonuç ver
- Karakterin yolculuğunu tamamla
- İsimli karakterlerin akıbetini belirt

YAZIM KURALLARI:
- TAM OLARAK 3 paragraf yaz
- Her paragraf 3-4 cümle olsun
- Duygusal ve etkileyici dil
- Karakterin adını kullan
- Sonlandırma hissi ver
- Detaylı ve tatmin edici sonuç

YAPMA:
- Seçenek sunma
- Hikayeyi yarıda bırakma
- Belirsiz sonuçlar
- Yeni maceralar başlatma

Şimdi $characterName'in hikayesini sonlandır.''';
  }

  /// İngilizce final prompt'u oluşturur
  String _buildEnglishFinalPrompt(
    GameCategory category,
    String characterName,
    List<String> history,
    String userInput,
  ) {
    final historyText = history.join('\n\n');

    return '''You are Sezyon story narrator. Conclude the story satisfyingly.

CHARACTER: $characterName
STATUS: STORY FINALE (15th turn or ending implication)

PREVIOUS STORY:
$historyText

FINAL EXPRESSION: "$userInput"

FINALE RULES:
- Resolve main conflict
- Determine $characterName's fate
- Provide satisfying conclusion
- Complete character's journey
- State fate of named characters

WRITING RULES:
- EXACTLY 3 paragraphs
- Each paragraph should be 3-4 sentences
- Emotional and impactful language
- Use character's name
- Give sense of closure
- Detailed and satisfying conclusion

DON'T:
- Offer choices
- Leave story unfinished
- Ambiguous endings
- Start new adventures

Now conclude $characterName's story.''';
  }

  /// Türkçe özet prompt'u oluşturur
  String _buildTurkishSummaryPrompt(
    GameCategory category,
    String characterName,
    List<String> history,
  ) {
    final historyText = history.join('\n\n');

    return '''Tamamlanan hikayenin özetini credits tarzında yaz.

KARAKTER: $characterName
KATEGORİ: ${category.displayName}

TAMAMLANAN HİKAYE:
$historyText

ÖZET KURALLARI:
- Hikayenin ana olaylarını kronolojik sırayla özetle
- $characterName'in yaptığı önemli kararları vurgula
- Duygusal ve atmosferik dil kullan
- İsimli karakterlerin rollerini belirt
- Hikayenin sonucunu ve etkisini açıkla

FORMAT:
"$characterName'in Hikayesi

[Ana olayların özeti]
[Önemli kararlar]
[Sonuç ve etki]

Bu macera..."

YAZIM KURALLARI:
- 3-4 paragraf
- Duygusal ve etkileyici dil
- Credits benzeri format

Sadece özeti yaz, başka hiçbir şey ekleme.''';
  }

  /// İngilizce özet prompt'u oluşturur
  String _buildEnglishSummaryPrompt(
    GameCategory category,
    String characterName,
    List<String> history,
  ) {
    final historyText = history.join('\n\n');

    return '''Write a credits-style summary of the completed story.

CHARACTER: $characterName
CATEGORY: ${category.displayName}

COMPLETED STORY:
$historyText

SUMMARY RULES:
- Summarize main events chronologically
- Highlight important decisions made by $characterName
- Use emotional and atmospheric language
- State roles of named characters
- Explain story's outcome and impact

FORMAT:
"The Story of $characterName

[Summary of main events]
[Important decisions]
[Outcome and impact]

This adventure..."

WRITING RULES:
- 3-4 paragraphs
- Emotional and impactful language
- Credits-like format

Only write the summary, add nothing else.''';
  }

  /// Türkçe kategori bağlamı
  String _getTurkishCategoryContext(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return '''SAVAŞ KATEGORİSİ - İSİMLENDİRME KURALLARI:
- Gerçek tarihi savaşlardan ilham al (1. Dünya Savaşı, 2. Dünya Savaşı, Çanakkale, Kurtuluş Savaşı vb.)
- Tarihi atmosfer ve gerçekçi detaylar
- İSİM KURALLARI: Savaşın dönemine ve yerine göre uygun isimler kullan:
  * Çanakkale/Kurtuluş Savaşı: Mehmet, Ahmet, Mustafa, Fatma, Ayşe, Zeynep
  * 1. Dünya Savaşı Avrupa: Hans, Wilhelm, Pierre, Marie, Giovanni, Anna
  * 2. Dünya Savaşı: Robert, James, Ivan, Katarina, Heinrich, Sofia
  * Vietnam Savaşı: John, Michael, Nguyen, Li, David, Maria
- Savaşın psikolojik ve fiziksel etkilerini yansıt
- Rütbe ve meslekleri dönemine uygun kullan''';
      case GameCategory.fantasy:
        return '''FANTASTİK KATEGORİSİ - İSİMLENDİRME KURALLARI:
- Büyülü dünya, ejderhalar, büyücüler, krallıklar
- İSİM KURALLARI: Fantastik atmosfere uygun mistik isimler:
  * Büyücüler: Eldara, Morgrim, Zephyra, Thalorin, Lyralei
  * Şövalyeler: Gareth, Aldric, Seraphina, Tristan, Isolde
  * Ejderhalar: Pyrion, Drakmor, Azureth, Vermillion, Shadowfang
  * Kraliyet: Aragorn, Galadriel, Thorin, Arwen, Legolas
- Epik atmosfer ve büyülü öğeler
- Kahramanlık ve macera teması
- İsimler karakterin rolüne uygun olsun''';
      case GameCategory.sciFi:
        return '''BİLİM KURGU KATEGORİSİ - İSİMLENDİRME KURALLARI:
- Uzak gelecek, uzay gemileri, yabancı gezegenler
- İSİM KURALLARI: Gelecek ve uzay temasına uygun isimler:
  * İnsan karakterler: Nova, Zara, Kai, Orion, Luna, Phoenix
  * Androidler/AI: X-7, ARIA-9, Nexus, Quantum, Cipher
  * Uzaylılar: Zyx'tar, Vel'koz, Qeth'ran, Mor'dun
  * Kaptanlar: Commander Nova, Captain Vega, Admiral Cosmos
- Teknolojik öğeler ve bilimsel kavramlar
- Keşif ve teknoloji teması
- İsimler futuristik ve evrensel olsun''';
      case GameCategory.mystery:
        return '''GİZEM KATEGORİSİ - İSİMLENDİRME KURALLARI:
- 1920'ler kasvetli şehir atmosferi (Art Deco dönemi)
- İSİM KURALLARI: 1920'lere uygun klasik isimler:
  * Dedektifler: Holmes, Watson, Marlowe, Poirot, Miss Marple
  * Aristokrasi: Lady Margaret, Lord Pemberton, Duchess Victoria
  * Şüpheliler: Charles Blackwood, Evelyn Sterling, Theodore Ashford
  * Hizmetliler: Mrs. Hudson, James the Butler, Mary the Maid
- Gizemli olaylar ve ipuçları
- Araştırma ve çözüm teması
- İsimler dönemin sosyal sınıfını yansıtsın''';
      case GameCategory.historical:
        return '''TARİHİ KATEGORİ - İSİMLENDİRME KURALLARI:
- Gerçek tarihi dönemlerden ilham al (Osmanlı, Roma, Orta Çağ vb.)
- İSİM KURALLARI: Dönemine ve bölgesine göre uygun isimler:
  * Osmanlı Dönemi: Mehmet Paşa, Süleyman Ağa, Fatma Hatun, Ayşe Sultan
  * Roma Dönemi: Marcus Aurelius, Gaius Julius, Livia, Octavia
  * Orta Çağ Avrupa: Sir William, Lord Edmund, Lady Catherine, Brother Thomas
  * Rönesans: Leonardo da Vinci, Michelangelo, Isabella d'Este
  * Antik Mısır: Amenhotep, Nefertiti, Ramses, Cleopatra
- Tarihi gerçeklere uygun atmosfer
- Dönemin kültürü ve yaşam tarzı
- Unvanlar ve sosyal statü dönemine uygun''';
      case GameCategory.apocalypse:
        return '''KIYAMET SONRASI KATEGORİ - İSİMLENDİRME KURALLARI:
- Medeniyetin çöktüğü dünya
- İSİM KURALLARI: Post-apokaliptik atmosfere uygun isimler:
  * Hayatta kalanlar: Marcus, Sarah, Kane, Raven, Phoenix, Storm
  * Grup liderleri: The Governor, Caesar, Alpha, Beta, Negan
  * Doktorlar: Dr. Sarah Chen, Dr. Marcus Webb, Dr. Elena Vasquez
  * Çocuklar: Hope, Faith, Dawn, Sage (umut veren isimler)
  * Kötü karakterler: Skull, Razor, Viper, Crow, Ash
- Hayatta kalma mücadelesi
- Umut ve dayanışma teması
- İsimler karakterin rolü ve kişiliğini yansıtsın
- Lakap tarzı isimler de kullanılabilir''';
    }
  }

  /// İngilizce kategori bağlamı
  String _getEnglishCategoryContext(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return '''WAR CATEGORY - NAMING RULES:
- Draw inspiration from real historical wars (WWI, WWII, Vietnam, Korean War etc.)
- Historical atmosphere and realistic details
- NAMING RULES: Use appropriate names for war period and location:
  * WWI Europe: Hans, Wilhelm, Pierre, Marie, Giovanni, Anna, Franz
  * WWII: Robert, James, Ivan, Katarina, Heinrich, Sofia, Winston
  * Vietnam War: John, Michael, Nguyen, Li, David, Maria, Rodriguez
  * Korean War: Kim, Park, Jackson, Thompson, Chen, Williams
- Reflect psychological and physical effects of war
- Use period-appropriate ranks and professions''';
      case GameCategory.fantasy:
        return '''FANTASY CATEGORY - NAMING RULES:
- Magical world, dragons, wizards, kingdoms
- NAMING RULES: Use mystical names fitting fantasy atmosphere:
  * Wizards: Eldara, Morgrim, Zephyra, Thalorin, Lyralei, Gandalf
  * Knights: Gareth, Aldric, Seraphina, Tristan, Isolde, Lancelot
  * Dragons: Pyrion, Drakmor, Azureth, Vermillion, Shadowfang, Bahamut
  * Royalty: Aragorn, Galadriel, Thorin, Arwen, Legolas, Elrond
- Epic atmosphere and magical elements
- Heroism and adventure theme
- Names should match character's role and nature''';
      case GameCategory.sciFi:
        return '''SCI-FI CATEGORY - NAMING RULES:
- Distant future, spaceships, alien planets
- NAMING RULES: Use futuristic and space-themed names:
  * Human characters: Nova, Zara, Kai, Orion, Luna, Phoenix, Vega
  * Androids/AI: X-7, ARIA-9, Nexus, Quantum, Cipher, CORTEX
  * Aliens: Zyx'tar, Vel'koz, Qeth'ran, Mor'dun, Xel'Naga
  * Captains: Commander Nova, Captain Vega, Admiral Cosmos, Fleet Admiral Orion
- Technological elements and scientific concepts
- Exploration and technology theme
- Names should sound futuristic and universal''';
      case GameCategory.mystery:
        return '''MYSTERY CATEGORY - NAMING RULES:
- 1920s gloomy city atmosphere (Art Deco period)
- NAMING RULES: Use classic 1920s appropriate names:
  * Detectives: Holmes, Watson, Marlowe, Poirot, Miss Marple, Inspector Morse
  * Aristocracy: Lady Margaret, Lord Pemberton, Duchess Victoria, Earl Blackwood
  * Suspects: Charles Blackwood, Evelyn Sterling, Theodore Ashford, Vivian Cross
  * Servants: Mrs. Hudson, James the Butler, Mary the Maid, Cook Mrs. Patmore
- Mysterious events and clues
- Investigation and solution theme
- Names should reflect period social class''';
      case GameCategory.historical:
        return '''HISTORICAL CATEGORY - NAMING RULES:
- Draw inspiration from real historical periods (Ottoman, Roman, Medieval etc.)
- NAMING RULES: Use period and region appropriate names:
  * Ottoman Period: Mehmet Pasha, Suleiman Agha, Fatma Hatun, Ayse Sultan
  * Roman Period: Marcus Aurelius, Gaius Julius, Livia, Octavia, Brutus
  * Medieval Europe: Sir William, Lord Edmund, Lady Catherine, Brother Thomas
  * Renaissance: Leonardo da Vinci, Michelangelo, Isabella d'Este, Lorenzo de Medici
  * Ancient Egypt: Amenhotep, Nefertiti, Ramses, Cleopatra, Tutankhamun
- Historically accurate atmosphere
- Period culture and lifestyle
- Titles and social status should match the era''';
      case GameCategory.apocalypse:
        return '''APOCALYPSE CATEGORY - NAMING RULES:
- World where civilization has collapsed
- NAMING RULES: Use post-apocalyptic atmosphere appropriate names:
  * Survivors: Marcus, Sarah, Kane, Raven, Phoenix, Storm, Ash
  * Group leaders: The Governor, Caesar, Alpha, Beta, Negan, The General
  * Doctors: Dr. Sarah Chen, Dr. Marcus Webb, Dr. Elena Vasquez, Dr. Kim
  * Children: Hope, Faith, Dawn, Sage, Grace (hopeful names)
  * Villains: Skull, Razor, Viper, Crow, Ash, The Reaper
- Survival struggle
- Hope and solidarity theme
- Names should reflect character's role and personality
- Nickname-style names are also acceptable''';
    }
  }

  /// Türkçe aşama açıklaması
  String _getTurkishPhaseDescription(StoryPhase phase) {
    switch (phase) {
      case StoryPhase.introduction:
        return 'GİRİŞ - Durumu tanıt ve atmosfer kur';
      case StoryPhase.development:
        return 'GELİŞME - Olayları geliştir ve gerilimi artır';
      case StoryPhase.climax:
        return 'DORUK - Ana çatışma ve kritik kararlar';
      case StoryPhase.conclusion:
        return 'SONUÇ - Hikayeyi sonlandırmaya hazırlan';
      default:
        return 'DEVAM - Hikayeyi sürdür';
    }
  }

  /// İngilizce aşama açıklaması
  String _getEnglishPhaseDescription(StoryPhase phase) {
    switch (phase) {
      case StoryPhase.introduction:
        return 'INTRODUCTION - Introduce situation and set atmosphere';
      case StoryPhase.development:
        return 'DEVELOPMENT - Develop events and increase tension';
      case StoryPhase.climax:
        return 'CLIMAX - Main conflict and critical decisions';
      case StoryPhase.conclusion:
        return 'CONCLUSION - Prepare to conclude story';
      default:
        return 'CONTINUE - Continue the story';
    }
  }

  /// Türkçe aşama kuralları
  String _getTurkishPhaseRules(StoryPhase phase) {
    switch (phase) {
      case StoryPhase.introduction:
        return '''- Dünyayı ve durumu tanıt
- Karakteri aksiyonun içine at
- Merak uyandıracak detaylar ver
- İsimli karakterler tanıt
- Henüz sonuç verme''';
      case StoryPhase.development:
        return '''- Olayları karmaşıklaştır
- Yeni karakterler/tehlikeler tanıt
- Gerilimi sürekli artır
- Ana hedefe doğru ilerle
- Henüz doruk noktasına çıkma''';
      case StoryPhase.climax:
        return '''- Ana çatışmayı başlat
- Kritik kararlar aldır
- Yoğun aksiyon ve drama
- Sonuca doğru hızlan
- Henüz bitirme''';
      case StoryPhase.conclusion:
        return '''- Ana çatışmayı çöz
- Hikayeyi sonlandırmaya hazırlan
- Tatmin edici sonuç ver
- Karakterin kaderini belirle''';
      default:
        return '- Hikayeyi doğal şekilde sürdür';
    }
  }

  /// İngilizce aşama kuralları
  String _getEnglishPhaseRules(StoryPhase phase) {
    switch (phase) {
      case StoryPhase.introduction:
        return '''- Introduce world and situation
- Throw character into action
- Give intriguing details
- Introduce named characters
- Don't give conclusions yet''';
      case StoryPhase.development:
        return '''- Complicate events
- Introduce new characters/dangers
- Continuously increase tension
- Progress toward main goal
- Don't reach climax yet''';
      case StoryPhase.climax:
        return '''- Start main conflict
- Force critical decisions
- Intense action and drama
- Accelerate toward conclusion
- Don't finish yet''';
      case StoryPhase.conclusion:
        return '''- Resolve main conflict
- Prepare to conclude story
- Provide satisfying conclusion
- Determine character's fate''';
      default:
        return '- Continue story naturally';
    }
  }

  /// Hikaye geçmişinden karakter bilgilerini çıkarır
  String _extractCharacterContext(List<String> history) {
    if (history.isEmpty) return 'Henüz karakter tanıtılmadı.';

    final characters = <String>[];
    final characterPattern = RegExp(
      r'([A-ZÇĞIİÖŞÜ][a-zçğıiöşü]+(?:\s+[A-ZÇĞIİÖŞÜ][a-zçğıiöşü]+)*)',
      multiLine: true,
    );

    for (final entry in history) {
      final matches = characterPattern.allMatches(entry);
      for (final match in matches) {
        final name = match.group(1);
        if (name != null &&
            name.length > 2 &&
            !name.contains('Sen') &&
            !name.contains('Siz') &&
            !characters.contains(name)) {
          characters.add(name);
        }
      }
    }

    if (characters.isEmpty) {
      return 'Henüz önemli karakter tanıtılmadı.';
    }

    return 'Hikayede bahsedilen karakterler: ${characters.take(5).join(', ')}. Bu karakterleri MUTLAKA hatırla ve tutarlı davran.';
  }

  /// Hikaye geçmişinden mekan bilgilerini çıkarır
  String _extractLocationContext(List<String> history) {
    if (history.isEmpty) return 'Henüz mekan belirtilmedi.';

    final locations = <String>[];
    final locationKeywords = [
      'hastane',
      'hospital',
      'klinik',
      'clinic',
      'oda',
      'room',
      'koridor',
      'corridor',
      'şehir',
      'city',
      'kasaba',
      'town',
      'köy',
      'village',
      'orman',
      'forest',
      'ev',
      'house',
      'bina',
      'building',
      'okul',
      'school',
      'ofis',
      'office',
      'park',
      'bahçe',
      'garden',
      'sokak',
      'street',
      'yol',
      'road',
      'kale',
      'castle',
      'saray',
      'palace',
      'tapınak',
      'temple',
      'kilise',
      'church',
    ];

    for (final entry in history) {
      for (final keyword in locationKeywords) {
        if (entry.toLowerCase().contains(keyword)) {
          final context = _extractLocationFromSentence(entry, keyword);
          if (context.isNotEmpty && !locations.contains(context)) {
            locations.add(context);
          }
        }
      }
    }

    if (locations.isEmpty) {
      return 'Mekan bilgisi net değil, tutarlı mekan kullan.';
    }

    return 'Hikayede geçen mekanlar: ${locations.take(3).join(', ')}. Mekan değişikliklerini mantıklı şekilde açıkla.';
  }

  /// Cümleden mekan bilgisini çıkarır
  String _extractLocationFromSentence(String sentence, String keyword) {
    final words = sentence.split(' ');
    final keywordIndex = words.indexWhere(
      (word) => word.toLowerCase().contains(keyword),
    );

    if (keywordIndex == -1) return '';

    final start = (keywordIndex - 2).clamp(0, words.length);
    final end = (keywordIndex + 3).clamp(0, words.length);

    return words
        .sublist(start, end)
        .join(' ')
        .replaceAll(RegExp(r'[^\w\sçğıiöşüÇĞIİÖŞÜ]'), '')
        .trim();
  }
}
