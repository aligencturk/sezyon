import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../services/logger_service.dart';
import 'category_selection_screen.dart';
import '../utils/custom_page_route.dart';
import '../widgets/banner_ad_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UserService _userService = UserService();
  final LoggerService _logger = LoggerService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  /// Mevcut giriş durumunu kontrol et
  Future<void> _checkExistingLogin() async {
    await _userService.initialize();
    if (_userService.isGooglePlayGamesUser && mounted) {
      _navigateToGame();
    }
  }

  /// Google ile giriş yap
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _userService.setGooglePlayGamesUser();

      if (_userService.isGooglePlayGamesUser && mounted) {
        _logger.info('Google Play Games girişi başarılı');
        _navigateToGame();
      } else {
        // Test modunda çalışması için misafir olarak devam et
        _logger.warning('Google girişi başarısız, misafir olarak devam ediliyor');
        await _continueAsGuest();
      }
    } catch (e) {
      _logger.error('Google giriş hatası', e);
      // Test modunda çalışması için hata mesajını gösterme
      // _showErrorSnackBar('Giriş sırasında bir hata oluştu');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Misafir olarak devam et
  Future<void> _continueAsGuest() async {
    await _userService.setGuestUser();
    _logger.info('Misafir girişi yapıldı');
    _navigateToGame();
  }

  /// Oyun ekranına geç
  void _navigateToGame() {
    Navigator.of(
      context,
    ).pushReplacement(FadePageRoute(child: const CategorySelectionScreen()));
  }

  /// Hata mesajı göster
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Ana içerik
          Expanded(
            child: Stack(
              children: [
                // Arka plan
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.6),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                // Ana içerik
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo ve başlık
                        Column(
                          children: [
                            Text(
                              'Sezyon',
                              style: GoogleFonts.merriweather(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hikayeni Yaz, Maceraya Başla',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 80),

                        // Giriş butonları
                        Column(
                          children: [
                            // Google ile giriş
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _signInWithGoogle,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.games,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                label: Text(
                                  _isLoading
                                      ? 'Giriş yapılıyor...'
                                      : 'Google Play Games ile Giriş',
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Misafir girişi
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _continueAsGuest,
                                icon: const Icon(
                                  Icons.person_outline,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Misafir Olarak Devam Et',
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Bilgi metni
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Google Play Games Avantajları:',
                                    style: GoogleFonts.sourceSans3(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Başarımları kilitle\n• Liderlik tablolarında yarış\n• İlerlemenizi bulutta kaydedin\n• Arkadaşlarınızla karşılaştırın',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Alt banner reklam
          const BannerAdWidget(
            height: 50,
            margin: EdgeInsets.only(bottom: 8),
          ),
        ],
      ),
    );
  }
}
