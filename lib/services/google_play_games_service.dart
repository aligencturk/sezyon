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
      final result = await GamesServices.signIn();
      _isSignedIn = result.isSuccess;

      if (_isSignedIn) {
        _logger.i('Google Play Games giriş başarılı');
      } else {
        _logger.w('Google Play Games giriş başarısız: ${result.message}');
      }

      return _isSignedIn;
    } catch (e) {
      _logger.e('Google Play Games giriş hatası: $e');
      return false;
    }
  }

  /// Google Play Games'den çıkış yap
  Future<void> signOut() async {
    try {
      await GamesServices.signOut();
      _isSignedIn = false;
      _logger.i('Google Play Games çıkış yapıldı');
    } catch (e) {
      _logger.e('Google Play Games çıkış hatası: $e');
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
        achievement: Achievement(androidID: achievementId),
      );
      if (result.isSuccess) {
        _logger.i('Başarım kilidi açıldı: $achievementId');
      } else {
        _logger.w('Başarım kilidi açılamadı: ${result.message}');
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
        score: Score(androidLeaderboardID: leaderboardId, value: score),
      );

      if (result.isSuccess) {
        _logger.i('Skor gönderildi: $score');
      } else {
        _logger.w('Skor gönderilemedi: ${result.message}');
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
    } catch (e) {
      _logger.e('Liderlik tablosunu gösterme hatası: $e');
    }
  }
}
