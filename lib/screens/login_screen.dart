import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../services/logger_service.dart';
import 'category_selection_screen.dart';
import '../utils/custom_page_route.dart';

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
        _showErrorSnackBar('Google girişi başarısız oldu');
      }
    } catch (e) {
      _logger.error('Google giriş hatası', e);
      _showErrorSnackBar('Giriş sırasında bir hata oluştu');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ve başlık
                Column(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 80,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 16),
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
                        color: Colors.white.withOpacity(0.8),
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
                    SizedBox(
                      width: double.infinity,
                      height: 56,
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
                            : const Icon(Icons.games, size: 24),
                        label: Text(
                          _isLoading
                              ? 'Giriş yapılıyor...'
                              : 'Google Play Games ile Giriş',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4A148C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Misafir girişi
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _continueAsGuest,
                        icon: const Icon(Icons.person_outline, size: 24),
                        label: Text(
                          'Misafir Olarak Devam Et',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                    color: Colors.white.withOpacity(0.1),
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
      ),
    );
  }
}
