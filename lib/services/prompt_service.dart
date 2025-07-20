import '../models/game_category.dart';
import '../models/message.dart';
import 'language_service.dart';

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

TEMEL KURALLAR:
- Kullanıcı hikayeyi seçimlerle değil, kendi yazdığı ifadelerle yönlendirir
- Sen bu ifadeleri anlamlandırır ve bağlamı takip ederek hikayeyi sürdürürsün
- Seçenek (A, B, C, D) ASLA sunma
- "Ne yapacaksın?" tarzı sorular sade ve tek cümlelik olur, her sahnede sorulmaz

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

YAZIM KURALLARI:
- TAM OLARAK 2 paragraf yaz
- Her paragraf 3-4 cümle olsun
- Atmosferik ve sürükleyici dil
- Karakterin adını kullan
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

CORE RULES:
- User directs the story not with choices, but with their own written expressions
- You understand these expressions and continue the story by following context
- NEVER offer choices (A, B, C, D)
- "What do you do?" type questions should be simple and single sentence, not asked in every scene

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

WRITING RULES:
- EXACTLY 2 paragraphs
- Each paragraph should be 3-4 sentences
- Atmospheric and engaging language
- Use character's name
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

    return '''Sen Sezyon hikaye anlatıcısısın. Kullanıcının ifadesini anlamlandır ve hikayeyi sürdür.

KARAKTER: $characterName
TUR SAYISI: $turnCount/15
MEVCUT AŞAMA: $phaseDescription

ÖNCEKİ HİKAYE:
$historyText

KULLANICI İFADESİ: "$userInput"

AŞAMA KURALLARI:
$phaseRules

TEMEL KURALLAR:
- Kullanıcının ifadesini anlamlandır ve sonucunu anlat
- $characterName'in adını kullan ve kişisel hitaplar yap
- İsimli karakterlerle etkileşim kur
- Bağlamı takip et, önceki olayları unutma
- Eylemler sonuç doğursun

YAZIM KURALLARI:
- TAM OLARAK 2 paragraf yaz
- Her paragraf 3-4 cümle olsun
- Atmosferik ve akıcı dil
- Her cümleyi tamamla
- Karakterin adını hikayede kullan
- Detaylı ve zengin anlatım

YAPMA:
- Seçenek sunma (A, B, C, D)
- "Ne yapacaksın?" her sahnede sorma
- Aşama sıralamasını bozma
- Hikayeyi erken bitirme

Şimdi $characterName'in "$userInput" ifadesinin sonucunu anlat.''';
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

    return '''You are Sezyon story narrator. Understand user's expression and continue the story.

CHARACTER: $characterName
TURN COUNT: $turnCount/15
CURRENT PHASE: $phaseDescription

PREVIOUS STORY:
$historyText

USER EXPRESSION: "$userInput"

PHASE RULES:
$phaseRules

CORE RULES:
- Understand user's expression and describe its outcome
- Use $characterName's name and make personal addresses
- Create interactions with named characters
- Follow context, don't forget previous events
- Actions should have consequences

WRITING RULES:
- EXACTLY 2 paragraphs
- Each paragraph should be 3-4 sentences
- Atmospheric and flowing language
- Complete every sentence
- Use character's name in story
- Detailed and rich narrative

DON'T:
- Offer choices (A, B, C, D)
- Ask "What do you do?" in every scene
- Break phase sequence
- End story early

Now describe the outcome of $characterName's "$userInput" expression.''';
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
        return '''SAVAŞ KATEGORİSİ:
- Gerçek tarihi savaşlardan ilham al (1. Dünya Savaşı, 2. Dünya Savaşı, Çanakkale, Kurtuluş Savaşı vb.)
- Tarihi atmosfer ve gerçekçi detaylar
- İsimli karakterler: Komutan Mehmet, Hemşire Anna, Gazeteci Pierre vb.
- Savaşın psikolojik ve fiziksel etkilerini yansıt''';
      case GameCategory.fantasy:
        return '''FANTASTİK KATEGORİSİ:
- Büyülü dünya, ejderhalar, büyücüler, krallıklar
- İsimli karakterler: Büyücü Eldara, Şövalye Gareth, Ejder Pyrion vb.
- Epik atmosfer ve büyülü öğeler
- Kahramanlık ve macera teması''';
      case GameCategory.sciFi:
        return '''BİLİM KURGU KATEGORİSİ:
- Uzak gelecek, uzay gemileri, yabancı gezegenler
- İsimli karakterler: Kaptan Nova, Dr. Zara, Android X-7 vb.
- Teknolojik öğeler ve bilimsel kavramlar
- Keşif ve teknoloji teması''';
      case GameCategory.mystery:
        return '''GİZEM KATEGORİSİ:
- 1920'ler kasvetli şehir atmosferi
- İsimli karakterler: Dedektif Holmes, Bayan Margaret, Şüpheli Charles vb.
- Gizemli olaylar ve ipuçları
- Araştırma ve çözüm teması''';
      case GameCategory.historical:
        return '''TARİHİ KATEGORİ:
- Gerçek tarihi dönemlerden ilham al (Osmanlı, Roma, Orta Çağ vb.)
- Tarihi gerçeklere uygun atmosfer
- İsimli karakterler: Tüccar Ahmet, Ressam Leonardo, Kont Wilhelm vb.
- Dönemin kültürü ve yaşam tarzı''';
      case GameCategory.apocalypse:
        return '''KIYAMET SONRASI KATEGORİ:
- Medeniyetin çöktüğü dünya
- İsimli karakterler: Rehber Marcus, Doktor Sarah, Çete Lideri Kane vb.
- Hayatta kalma mücadelesi
- Umut ve dayanışma teması''';
    }
  }

  /// İngilizce kategori bağlamı
  String _getEnglishCategoryContext(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return '''WAR CATEGORY:
- Draw inspiration from real historical wars (WWI, WWII, Vietnam, Korean War etc.)
- Historical atmosphere and realistic details
- Named characters: Commander Smith, Nurse Marie, Journalist Paul etc.
- Reflect psychological and physical effects of war''';
      case GameCategory.fantasy:
        return '''FANTASY CATEGORY:
- Magical world, dragons, wizards, kingdoms
- Named characters: Wizard Eldara, Knight Gareth, Dragon Pyrion etc.
- Epic atmosphere and magical elements
- Heroism and adventure theme''';
      case GameCategory.sciFi:
        return '''SCI-FI CATEGORY:
- Distant future, spaceships, alien planets
- Named characters: Captain Nova, Dr. Zara, Android X-7 etc.
- Technological elements and scientific concepts
- Exploration and technology theme''';
      case GameCategory.mystery:
        return '''MYSTERY CATEGORY:
- 1920s gloomy city atmosphere
- Named characters: Detective Holmes, Lady Margaret, Suspect Charles etc.
- Mysterious events and clues
- Investigation and solution theme''';
      case GameCategory.historical:
        return '''HISTORICAL CATEGORY:
- Draw inspiration from real historical periods (Ottoman, Roman, Medieval etc.)
- Historically accurate atmosphere
- Named characters: Merchant Ahmed, Artist Leonardo, Count Wilhelm etc.
- Period culture and lifestyle''';
      case GameCategory.apocalypse:
        return '''APOCALYPSE CATEGORY:
- World where civilization has collapsed
- Named characters: Guide Marcus, Doctor Sarah, Gang Leader Kane etc.
- Survival struggle
- Hope and solidarity theme''';
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
}
