import 'package:games_services/games_services.dart';
import 'package:logger/logger.dart';

class GooglePlayGamesService {
  static final GooglePlayGamesService _instance =
      GooglePlayGamesService._internal();
  factory GooglePlayGamesService() => _instance;
  GooglePlayGamesService._internal();

  final Logger _logger = Logger();
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  /// Google Play Games'e giriş yap
  Future<bool> signIn() async {
    try {
      // Test modunda çalışıyor mu kontrol et
      final isSignedIn = await GamesServices.isSignedIn;
      if (isSignedIn) {
        _isSignedIn = true;
        _logger.i('Google Play Games zaten giriş yapılmış');
        return true;
      }

      final result = await GamesServices.signIn();
      _isSignedIn = result == 'success';

      if (_isSignedIn) {
        _logger.i('Google Play Games giriş başarılı');
      } else {
        _logger.w('Google Play Games giriş başarısız: $result');
        // Test modunda çalışması için false döndür ama hata fırlatma
        _isSignedIn = false;
      }

      return _isSignedIn;
    } catch (e) {
      _logger.e('Google Play Games giriş hatası: $e');
      _isSignedIn = false;
      // Test modunda çalışması için false döndür ama hata fırlatma
      return false;
    }
  }

  /// Giriş durumunu kontrol et
  Future<bool> isSignedInAsync() async {
    try {
      final result = await GamesServices.isSignedIn;
      _isSignedIn = result;
      return _isSignedIn;
    } catch (e) {
      _logger.e('Giriş durumu kontrol hatası: $e');
      _isSignedIn = false;
      return false;
    }
  }

  /// Başarım kilitle
  Future<void> unlockAchievement(String achievementId) async {
    if (!_isSignedIn) {
      _logger.w('Google Play Games\'e giriş yapılmamış');
      return;
    }

    try {
      final result = await GamesServices.unlock(
        achievement: Achievement(
          androidID: achievementId,
          iOSID: achievementId, // iOS için de aynı ID kullanıyoruz
        ),
      );

      if (result == 'success') {
        _logger.i('Başarım kilidi açıldı: $achievementId');
      } else {
        _logger.w('Başarım kilidi açılamadı: $result');
      }
    } catch (e) {
      _logger.e('Başarım kilidi açma hatası: $e');
    }
  }

  /// Liderlik tablosuna skor gönder
  Future<void> submitScore(String leaderboardId, int score) async {
    if (!_isSignedIn) {
      _logger.w('Google Play Games\'e giriş yapılmamış');
      return;
    }

    try {
      final result = await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardId,
          iOSLeaderboardID: leaderboardId, // iOS için de aynı ID
          value: score,
        ),
      );

      if (result == 'success') {
        _logger.i('Skor gönderildi: $score');
      } else {
        _logger.w('Skor gönderilemedi: $result');
      }
    } catch (e) {
      _logger.e('Skor gönderme hatası: $e');
    }
  }

  /// Başarımları göster
  Future<void> showAchievements() async {
    if (!_isSignedIn) {
      _logger.w('Google Play Games\'e giriş yapılmamış');
      return;
    }

    try {
      await GamesServices.showAchievements();
      _logger.i('Başarımlar gösterildi');
    } catch (e) {
      _logger.e('Başarımları gösterme hatası: $e');
    }
  }

  /// Liderlik tablosunu göster
  Future<void> showLeaderboard(String leaderboardId) async {
    if (!_isSignedIn) {
      _logger.w('Google Play Games\'e giriş yapılmamış');
      return;
    }

    try {
      await GamesServices.showLeaderboards(
        iOSLeaderboardID: leaderboardId,
        androidLeaderboardID: leaderboardId,
      );
      _logger.i('Liderlik tablosu gösterildi: $leaderboardId');
    } catch (e) {
      _logger.e('Liderlik tablosunu gösterme hatası: $e');
    }
  }

  /// Oyuncu bilgilerini al
  Future<String?> getPlayerName() async {
    if (!_isSignedIn) {
      return null;
    }

    try {
      return await GamesServices.getPlayerName();
    } catch (e) {
      _logger.e('Oyuncu adı alma hatası: $e');
      return null;
    }
  }

  /// Oyuncu ID'sini al
  Future<String?> getPlayerId() async {
    if (!_isSignedIn) {
      return null;
    }

    try {
      return await GamesServices.getPlayerID();
    } catch (e) {
      _logger.e('Oyuncu ID alma hatası: $e');
      return null;
    }
  }
}
