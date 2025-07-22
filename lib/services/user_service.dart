import 'package:shared_preferences/shared_preferences.dart';
import 'google_play_games_service.dart';
import 'logger_service.dart';
import 'cloud_save_service.dart';

enum UserType { guest, googlePlayGames }

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final GooglePlayGamesService _gamesService = GooglePlayGamesService();
  final LoggerService _logger = LoggerService();
  CloudSaveService? _cloudSaveService;

  UserType _userType = UserType.guest;
  String? _userName;
  String? _userId;
  bool _isInitialized = false;

  // Getters
  UserType get userType => _userType;
  String? get userName => _userName;
  String? get userId => _userId;
  bool get isGooglePlayGamesUser => _userType == UserType.googlePlayGames;
  bool get isGuest => _userType == UserType.guest;
  bool get isInitialized => _isInitialized;
  CloudSaveService get cloudSave {
    if (_cloudSaveService == null) {
      _cloudSaveService = CloudSaveService();
      // Callback'i ayarla
      _cloudSaveService!.setUserServiceCallback(() => isGooglePlayGamesUser);
    }
    return _cloudSaveService!;
  }

  /// Servisi başlat ve kullanıcı durumunu yükle
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserType = prefs.getString('user_type');

      if (savedUserType == 'google_play_games') {
        // Google Play Games giriş durumunu kontrol et
        final isSignedIn = await _gamesService.isSignedInAsync();
        if (isSignedIn) {
          await _setGooglePlayGamesUser();
        } else {
          await _setGuestUser();
        }
      } else {
        await _setGuestUser();
      }

      // CloudSaveService'i başlat ve yerel kayıtları yükle
      await cloudSave.loadLocalSave();

      _isInitialized = true;
      _logger.info('User service başlatıldı - Kullanıcı tipi: $_userType');
    } catch (e) {
      _logger.error('User service başlatılırken hata', e);
      await _setGuestUser();
      _isInitialized = true;
    }
  }

  /// Google Play Games kullanıcısı olarak ayarla
  Future<void> setGooglePlayGamesUser() async {
    final success = await _gamesService.signIn();
    if (success) {
      await _setGooglePlayGamesUser();
      await _saveUserType('google_play_games');

      // Bulut kayıtları senkronize et
      await cloudSave.syncWithCloud();
    } else {
      throw Exception('Google Play Games girişi başarısız');
    }
  }

  /// Misafir kullanıcı olarak ayarla
  Future<void> setGuestUser() async {
    await _setGuestUser();
    await _saveUserType('guest');
  }

  /// Google Play Games kullanıcı bilgilerini yükle
  Future<void> _setGooglePlayGamesUser() async {
    _userType = UserType.googlePlayGames;

    try {
      _userName = await _gamesService.getPlayerName();
      _userId = await _gamesService.getPlayerId();

      _logger.info('Google Play Games kullanıcısı: $_userName ($_userId)');
    } catch (e) {
      _logger.error('Google Play Games kullanıcı bilgileri alınamadı', e);
      _userName = 'Google Oyuncusu';
      _userId = null;
    }
  }

  /// Misafir kullanıcı bilgilerini ayarla
  Future<void> _setGuestUser() async {
    _userType = UserType.guest;
    _userName = 'Misafir';
    _userId = null;

    _logger.info('Misafir kullanıcı olarak ayarlandı');
  }

  /// Kullanıcı tipini kaydet
  Future<void> _saveUserType(String userType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', userType);
    } catch (e) {
      _logger.error('Kullanıcı tipi kaydedilemedi', e);
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      await _setGuestUser();

      _logger.info('Kullanıcı çıkış yaptı');
    } catch (e) {
      _logger.error('Çıkış yapılırken hata', e);
    }
  }

  /// Başarım kilitle (sadece Google Play Games kullanıcıları için)
  Future<void> unlockAchievement(String achievementId) async {
    if (_userType == UserType.googlePlayGames) {
      await _gamesService.unlockAchievement(achievementId);
    } else {
      _logger.info('Misafir kullanıcı - başarım kilitlenemedi: $achievementId');
    }
  }

  /// Skor gönder (sadece Google Play Games kullanıcıları için)
  Future<void> submitScore(String leaderboardId, int score) async {
    if (_userType == UserType.googlePlayGames) {
      await _gamesService.submitScore(leaderboardId, score);
    } else {
      _logger.info('Misafir kullanıcı - skor gönderilemedi: $score');
    }
  }

  /// Başarımları göster (sadece Google Play Games kullanıcıları için)
  Future<void> showAchievements() async {
    if (_userType == UserType.googlePlayGames) {
      await _gamesService.showAchievements();
    } else {
      _logger.info('Misafir kullanıcı - başarımlar gösterilemiyor');
    }
  }

  /// Liderlik tablosunu göster (sadece Google Play Games kullanıcıları için)
  Future<void> showLeaderboard(String leaderboardId) async {
    if (_userType == UserType.googlePlayGames) {
      await _gamesService.showLeaderboard(leaderboardId);
    } else {
      _logger.info('Misafir kullanıcı - liderlik tablosu gösterilemiyor');
    }
  }
}
