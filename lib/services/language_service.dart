import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Desteklenen diller
enum AppLanguage {
  turkish('tr', 'Türkçe', '🇹🇷'),
  english('en', 'English', '🇺🇸');

  const AppLanguage(this.code, this.displayName, this.flag);

  final String code;
  final String displayName;
  final String flag;
}

/// Dil yönetimi servisi
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _languageKey = 'selected_language';
  final LoggerService _logger = LoggerService();

  AppLanguage _currentLanguage = AppLanguage.turkish;

  /// Mevcut dili döndürür
  AppLanguage get currentLanguage => _currentLanguage;

  /// Mevcut dil kodunu döndürür
  String get currentLanguageCode => _currentLanguage.code;

  /// Türkçe mi kontrol eder
  bool get isTurkish => _currentLanguage == AppLanguage.turkish;

  /// İngilizce mi kontrol eder
  bool get isEnglish => _currentLanguage == AppLanguage.english;

  /// İsme tamlayan eki ekler: Türkçe'de ünlü uyumuna göre (Ali'nin, Alı'nın), İngilizce'de 's
  String possessive(String name) {
    if (name.isEmpty) return name;
    if (!isTurkish) return "$name's";

    const vowels = 'aeıioöuü';
    final lower = name.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
    final lastVowel = lower
        .split('')
        .lastWhere(vowels.contains, orElse: () => 'e');
    final suffix = switch (lastVowel) {
      'a' || 'ı' => 'ın',
      'o' || 'u' => 'un',
      'ö' || 'ü' => 'ün',
      _ => 'in',
    };
    final endsWithVowel = vowels.contains(lower[lower.length - 1]);
    return "$name'${endsWithVowel ? 'n' : ''}$suffix";
  }

  /// Dil tercihini yükler
  Future<void> loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        _currentLanguage = AppLanguage.values.firstWhere(
          (lang) => lang.code == languageCode,
          orElse: () => AppLanguage.turkish,
        );
      }

      _logger.info('🌍 Dil tercihi yüklendi: ${_currentLanguage.displayName}');
    } catch (e, stackTrace) {
      _logger.error('Dil tercihi yüklenirken hata oluştu', e, stackTrace);
    }
  }

  /// Dil tercihini kaydeder
  Future<bool> setLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);

      _currentLanguage = language;
      _logger.info('🌍 Dil değiştirildi: ${language.displayName}');

      return true;
    } catch (e, stackTrace) {
      _logger.error('Dil tercihi kaydedilirken hata oluştu', e, stackTrace);
      return false;
    }
  }

  /// Lokalize metinleri döndürür
  String getLocalizedText(String turkishText, String englishText) {
    return _currentLanguage == AppLanguage.turkish ? turkishText : englishText;
  }

  /// UI metinlerini döndürür
  String get appTitle => getLocalizedText('RPG Oyunu', 'RPG Game');

  String get categorySelectionTitle => getLocalizedText('SEZYON', 'SEZYON');

  String get categorySelectionSubtitle => getLocalizedText(
    'Maceranın hangi türde başlamasını istiyorsunuz?',
    'What type of adventure would you like to start?',
  );

  String get settings => getLocalizedText('Ayarlar', 'Settings');

  String get language => getLocalizedText('Dil', 'Language');

  String get selectLanguage => getLocalizedText('Dil Seçin', 'Select Language');

  String get restart => getLocalizedText('Yeniden Başlat', 'Restart');

  String get restartGame =>
      getLocalizedText('Oyunu Yeniden Başlat', 'Restart Game');

  String get restartConfirmation => getLocalizedText(
    'Mevcut hikayeniz silinecek. Emin misiniz?',
    'Your current story will be deleted. Are you sure?',
  );

  String get cancel => getLocalizedText('İptal', 'Cancel');

  String get ok => getLocalizedText('Tamam', 'OK');

  String get error => getLocalizedText('Hata', 'Error');

  String get loading => getLocalizedText('Yükleniyor...', 'Loading...');

  String get storyLoading => getLocalizedText(
    'Hikayeniz hazırlanıyor...',
    'Your story is being prepared...',
  );

  String get storyContinuing => getLocalizedText(
    'Hikayenize devam ediliyor...',
    'Continuing your story...',
  );

  String get inputHint =>
      getLocalizedText('Ne yapmak istiyorsunuz?', 'What would you like to do?');

  String get audioSettings =>
      getLocalizedText('Ses Ayarları', 'Audio Settings');

  String get musicVolume => getLocalizedText('Müzik Sesi', 'Music Volume');

  String get soundEffectsVolume =>
      getLocalizedText('Ses Efektleri', 'Sound Effects');

  String get musicEnabled => getLocalizedText('Müzik Açık', 'Music Enabled');

  String get soundEffectsEnabled =>
      getLocalizedText('Ses Efektleri Açık', 'Sound Effects Enabled');

  String get mute => getLocalizedText('Sessiz', 'Mute');

  String get unmute => getLocalizedText('Sesi Aç', 'Unmute');

  /// Kategori isimlerini döndürür
  String getCategoryName(String categoryKey) {
    switch (categoryKey) {
      case 'war':
        return getLocalizedText('Savaş', 'War');
      case 'sciFi':
        return getLocalizedText('Bilim Kurgu', 'Sci-Fi');
      case 'fantasy':
        return getLocalizedText('Fantastik', 'Fantasy');
      case 'mystery':
        return getLocalizedText('Gizem', 'Mystery');
      case 'historical':
        return getLocalizedText('Tarihi', 'Historical');
      case 'apocalypse':
        return getLocalizedText('Kıyamet', 'Apocalypse');
      default:
        return categoryKey;
    }
  }

  /// Macera başlığını döndürür
  String getAdventureTitle(String categoryKey) {
    final categoryName = getCategoryName(categoryKey);
    return getLocalizedText(
      '$categoryName Macerası',
      '$categoryName Adventure',
    );
  }

  /// Hikaye sonu metinleri
  String get storyCompleted =>
      getLocalizedText('Hikaye Tamamlandı!', 'Story Completed!');

  String get storyEndMessage => getLocalizedText(
    'Maceran sona erdi. Yeni bir hikaye başlatmak ister misin?',
    'Your adventure has ended. Would you like to start a new story?',
  );

  String get mainMenu => getLocalizedText('Ana Menü', 'Main Menu');

  String get newStory => getLocalizedText('Yeni Hikaye', 'New Story');

  String get storySummary => getLocalizedText('Hikaye Özeti', 'Story Summary');

  String get continueStory =>
      getLocalizedText('Hikayeye Devam Et', 'Continue Story');

  String get epilogue => getLocalizedText('Epilog', 'Epilogue');

  String get storySummaryQuestion => getLocalizedText(
    'Hikayenizin özetini görmek ister misiniz?',
    'Would you like to see your story summary?',
  );

  String get storySummaryLoading => getLocalizedText(
    'Hikaye özeti yükleniyor...',
    'Story summary loading...',
  );
}
