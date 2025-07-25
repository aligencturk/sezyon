import 'package:flutter/material.dart';
import '../services/google_play_games_service.dart';

class GooglePlayGamesWidget extends StatefulWidget {
  const GooglePlayGamesWidget({super.key});

  @override
  State<GooglePlayGamesWidget> createState() => _GooglePlayGamesWidgetState();
}

class _GooglePlayGamesWidgetState extends State<GooglePlayGamesWidget> {
  final GooglePlayGamesService _gamesService = GooglePlayGamesService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Giriş durumu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _gamesService.isSignedIn ? Icons.check_circle : Icons.cancel,
                color: _gamesService.isSignedIn ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _gamesService.isSignedIn
                    ? 'Google Play Games\'e bağlı'
                    : 'Google Play Games\'e bağlı değil',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Butonlar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _gamesService.isSignedIn
                  ? null
                  : () async {
                      final success = await _gamesService.signIn();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Google Play Games\'e giriş yapıldı!',
                            ),
                          ),
                        );
                      }
                      setState(() {});
                    },
              icon: const Icon(Icons.login),
              label: const Text('Giriş Yap'),
            ),

            ElevatedButton.icon(
              onPressed: _gamesService.isSignedIn
                  ? () {
                      _gamesService.showAchievements();
                    }
                  : null,
              icon: const Icon(Icons.emoji_events),
              label: const Text('Başarımlar'),
            ),

            ElevatedButton.icon(
              onPressed: _gamesService.isSignedIn
                  ? () {
                      // Örnek liderlik tablosu ID'si - gerçek ID ile değiştirin
                      _gamesService.showLeaderboard('YOUR_LEADERBOARD_ID');
                    }
                  : null,
              icon: const Icon(Icons.leaderboard),
              label: const Text('Liderlik'),
            ),
          ],
        ),
      ],
    );
  }
}

// Oyun içinde kullanım için yardımcı fonksiyonlar
class GameIntegration {
  static final GooglePlayGamesService _gamesService = GooglePlayGamesService();

  // Hikaye tamamlandığında başarım kilitle
  static Future<void> onStoryCompleted(String category) async {
    switch (category.toLowerCase()) {
      case 'war':
      case 'savaş':
        await _gamesService.unlockAchievement('CgkI_EXAMPLE_WAR_MASTER');
        break;
      case 'fantasy':
      case 'fantastik':
        await _gamesService.unlockAchievement('CgkI_EXAMPLE_FANTASY_MASTER');
        break;
      case 'scifi':
      case 'bilim kurgu':
        await _gamesService.unlockAchievement('CgkI_EXAMPLE_SCIFI_MASTER');
        break;
      case 'mystery':
      case 'gizem':
        await _gamesService.unlockAchievement('CgkI_EXAMPLE_MYSTERY_MASTER');
        break;
      case 'historical':
      case 'tarih':
        await _gamesService.unlockAchievement('CgkI_EXAMPLE_HISTORICAL_MASTER');
        break;
      case 'apocalypse':
      case 'kıyamet':
        await _gamesService.unlockAchievement('CgkI_EXAMPLE_APOCALYPSE_MASTER');
        break;
    }
  }

  // Toplam hikaye sayısını liderlik tablosuna gönder
  static Future<void> updateStoryCount(int totalStories) async {
    await _gamesService.submitScore('TOTAL_STORIES_LEADERBOARD', totalStories);
  }

  // Günlük hikaye sayısını liderlik tablosuna gönder
  static Future<void> updateDailyStories(int dailyStories) async {
    await _gamesService.submitScore('DAILY_STORIES_LEADERBOARD', dailyStories);
  }

  // Özel başarımlar
  static Future<void> checkSpecialAchievements({
    required int totalStories,
    required int consecutiveDays,
    required bool firstTime,
  }) async {
    // İlk hikaye
    if (firstTime) {
      await _gamesService.unlockAchievement('FIRST_STORY');
    }

    // 10 hikaye tamamlama
    if (totalStories >= 10) {
      await _gamesService.unlockAchievement('STORY_COLLECTOR');
    }

    // 50 hikaye tamamlama
    if (totalStories >= 50) {
      await _gamesService.unlockAchievement('STORY_MASTER');
    }

    // 100 hikaye tamamlama
    if (totalStories >= 100) {
      await _gamesService.unlockAchievement('STORY_LEGEND');
    }

    // 7 gün üst üste
    if (consecutiveDays >= 7) {
      await _gamesService.unlockAchievement('WEEKLY_READER');
    }

    // 30 gün üst üste
    if (consecutiveDays >= 30) {
      await _gamesService.unlockAchievement('MONTHLY_READER');
    }
  }
}
