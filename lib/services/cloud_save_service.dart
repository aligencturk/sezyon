import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Oyun verilerini bulutta saklama servisi
class CloudSaveService {
  static final CloudSaveService _instance = CloudSaveService._internal();
  factory CloudSaveService() => _instance;
  CloudSaveService._internal();

  final LoggerService _logger = LoggerService();

  // UserService durumunu kontrol etmek için callback
  bool Function()? _isGooglePlayGamesUserCallback;

  /// UserService callback'ini ayarla
  void setUserServiceCallback(bool Function() callback) {
    _isGooglePlayGamesUserCallback = callback;
  }

  bool get _isGooglePlayGamesUser {
    return _isGooglePlayGamesUserCallback?.call() ?? false;
  }

  /// Oyun verisi modeli
  Map<String, dynamic> _gameData = {
    'playerName': '',
    'completedStories': <String>[],
    'achievements': <String>[],
    'totalPlayTime': 0,
    'favoriteCategories': <String>[],
    'settings': {'soundEnabled': true, 'musicEnabled': true, 'language': 'tr'},
    'statistics': {
      'storiesCompleted': 0,
      'totalChoicesMade': 0,
      'averageStoryLength': 0,
    },
    'lastSaved': DateTime.now().toIso8601String(),
  };

  /// Oyun verisini al
  Map<String, dynamic> get gameData => Map.from(_gameData);

  /// Yerel kayıt yükle
  Future<void> loadLocalSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('game_data');

      if (savedData != null) {
        _gameData = Map<String, dynamic>.from(jsonDecode(savedData));
        _logger.info('Yerel kayıt yüklendi');
      } else {
        _logger.info('Yerel kayıt bulunamadı, varsayılan veriler kullanılıyor');
      }
    } catch (e) {
      _logger.error('Yerel kayıt yüklenirken hata', e);
    }
  }

  /// Yerel kayıt
  Future<void> saveLocal() async {
    try {
      _gameData['lastSaved'] = DateTime.now().toIso8601String();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_data', jsonEncode(_gameData));

      _logger.info('Oyun verisi yerel olarak kaydedildi');
    } catch (e) {
      _logger.error('Yerel kayıt hatası', e);
    }
  }

  /// Bulut kayıt (Google Play Games kullanıcıları için)
  Future<bool> saveToCloud() async {
    if (!_isGooglePlayGamesUser) {
      _logger.info('Misafir kullanıcı - bulut kayıt yapılamıyor');
      return false;
    }

    try {
      // TODO: Firebase Firestore entegrasyonu
      // Şimdilik yerel kayıt yapıyoruz
      await saveLocal();

      _logger.info('Bulut kayıt simülasyonu tamamlandı');
      return true;
    } catch (e) {
      _logger.error('Bulut kayıt hatası', e);
      return false;
    }
  }

  /// Buluttan yükle (Google Play Games kullanıcıları için)
  Future<bool> loadFromCloud() async {
    if (!_isGooglePlayGamesUser) {
      _logger.info('Misafir kullanıcı - buluttan yükleme yapılamıyor');
      return false;
    }

    try {
      // TODO: Firebase Firestore entegrasyonu
      // Şimdilik yerel kayıttan yüklüyoruz
      await loadLocalSave();

      _logger.info('Bulut yükleme simülasyonu tamamlandı');
      return true;
    } catch (e) {
      _logger.error('Buluttan yükleme hatası', e);
      return false;
    }
  }

  /// Oyuncu adını güncelle
  void updatePlayerName(String name) {
    _gameData['playerName'] = name;
    _autoSave();
  }

  /// Tamamlanan hikaye ekle
  void addCompletedStory(String storyId) {
    final completed = List<String>.from(_gameData['completedStories']);
    if (!completed.contains(storyId)) {
      completed.add(storyId);
      _gameData['completedStories'] = completed;

      // İstatistikleri güncelle
      _gameData['statistics']['storiesCompleted'] = completed.length;

      _autoSave();
      _logger.info('Hikaye tamamlandı: $storyId');
    }
  }

  /// Başarım ekle
  void addAchievement(String achievementId) {
    final achievements = List<String>.from(_gameData['achievements']);
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      _gameData['achievements'] = achievements;

      _autoSave();
      _logger.info('Başarım eklendi: $achievementId');
    }
  }

  /// Oyun süresini güncelle
  void updatePlayTime(int additionalSeconds) {
    _gameData['totalPlayTime'] =
        (_gameData['totalPlayTime'] ?? 0) + additionalSeconds;
    _autoSave();
  }

  /// Favori kategori ekle
  void addFavoriteCategory(String category) {
    final favorites = List<String>.from(_gameData['favoriteCategories']);
    if (!favorites.contains(category)) {
      favorites.add(category);
      _gameData['favoriteCategories'] = favorites;
      _autoSave();
    }
  }

  /// Ayarları güncelle
  void updateSettings(Map<String, dynamic> newSettings) {
    _gameData['settings'] = {..._gameData['settings'], ...newSettings};
    _autoSave();
  }

  /// Seçim sayısını artır
  void incrementChoicesMade() {
    _gameData['statistics']['totalChoicesMade'] =
        (_gameData['statistics']['totalChoicesMade'] ?? 0) + 1;
    _autoSave();
  }

  /// Otomatik kayıt
  Future<void> _autoSave() async {
    await saveLocal();

    // Google Play Games kullanıcısıysa buluta da kaydet
    if (_isGooglePlayGamesUser) {
      await saveToCloud();
    }
  }

  /// Kayıt verilerini sıfırla
  Future<void> resetGameData() async {
    _gameData = {
      'playerName': '',
      'completedStories': <String>[],
      'achievements': <String>[],
      'totalPlayTime': 0,
      'favoriteCategories': <String>[],
      'settings': {
        'soundEnabled': true,
        'musicEnabled': true,
        'language': 'tr',
      },
      'statistics': {
        'storiesCompleted': 0,
        'totalChoicesMade': 0,
        'averageStoryLength': 0,
      },
      'lastSaved': DateTime.now().toIso8601String(),
    };

    await saveLocal();
    _logger.info('Oyun verisi sıfırlandı');
  }

  /// Kayıt verilerini dışa aktar (JSON formatında)
  String exportGameData() {
    return jsonEncode(_gameData);
  }

  /// Kayıt verilerini içe aktar
  Future<bool> importGameData(String jsonData) async {
    try {
      final importedData = Map<String, dynamic>.from(jsonDecode(jsonData));
      _gameData = importedData;
      await saveLocal();

      _logger.info('Oyun verisi içe aktarıldı');
      return true;
    } catch (e) {
      _logger.error('Veri içe aktarma hatası', e);
      return false;
    }
  }

  /// Senkronizasyon durumu kontrolü
  bool get needsSync {
    if (!_isGooglePlayGamesUser) return false;

    // Son kayıt zamanını kontrol et
    final lastSaved = DateTime.tryParse(_gameData['lastSaved'] ?? '');
    if (lastSaved == null) return true;

    // 5 dakikadan eski kayıtlar senkronize edilmeli
    return DateTime.now().difference(lastSaved).inMinutes > 5;
  }

  /// Manuel senkronizasyon
  Future<bool> syncWithCloud() async {
    if (!_isGooglePlayGamesUser) {
      _logger.info('Misafir kullanıcı - senkronizasyon yapılamıyor');
      return false;
    }

    try {
      // Önce buluttan yükle
      await loadFromCloud();

      // Sonra buluta kaydet
      await saveToCloud();

      _logger.info('Bulut senkronizasyonu tamamlandı');
      return true;
    } catch (e) {
      _logger.error('Senkronizasyon hatası', e);
      return false;
    }
  }
}
