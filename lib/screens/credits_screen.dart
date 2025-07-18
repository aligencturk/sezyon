import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/language_service.dart';
import '../services/audio_service.dart';

/// Credits ekranı
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late Animation<Offset> _scrollAnimation;
  final LanguageService _languageService = LanguageService();
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    
    // Scroll animasyonu
    _scrollController = AnimationController(
      duration: const Duration(seconds: 30), // 30 saniye sürecek
      vsync: this,
    );
    
    _scrollAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Aşağıdan başla
      end: const Offset(0, -1.2),   // Daha fazla yukarıya git
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: Curves.linear,
    ));
    
    // Animasyonu başlat
    _scrollController.forward();
    
    // Credits müziği çal (eğer varsa) - mevcut dosya yoksa kaldır
    // _audioService.playSoundEffect('audio/credits.ogg');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitleStyle = GoogleFonts.merriweather(fontSize: 20);
    final double topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _languageService.getLocalizedText('Jenerik', 'Credits'),
          style: appBarTitleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Arka plan gradyanı
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1a1a1a),
                  Colors.black,
                  Color(0xFF1a1a1a),
                ],
              ),
            ),
          ),
          
          // Kayan credits içeriği
          SlideTransition(
            position: _scrollAnimation,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: kToolbarHeight + topPadding), // AppBar ve status bar yüksekliği kadar boşluk
                    // AppBar başlığı ile aynı hizada başlık
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Sezyon',
                        style: appBarTitleStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 10,
                              color: Colors.purple.withOpacity(0.5),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Oyun başlığı
                    _buildTitle('Sezyon'),
                    const SizedBox(height: 50),
                    
                    // Geliştirici
                    _buildSection(
                      _languageService.getLocalizedText('Geliştirici', 'Developer'),
                      'Ali Genç Türk',
                    ),
                    const SizedBox(height: 40),
                    
                    // Müzikler
                    _buildSection(
                      _languageService.getLocalizedText('Müzikler', 'Music'),
                      '',
                    ),
                    const SizedBox(height: 20),
                    
                    // Ana menü müziği
                    _buildMusicCredit(
                      'Ana Menü Müziği',
                      'lucafrancini - Atmospheric Glitch',
                      'Ana Menü',
                    ),
                    // Gizem müziği
                    _buildMusicCredit(
                      'Gizem Kategorisi Müziği',
                      'Alexandr Zhelanov - Mystery Manor',
                      'Gizem Senaryosu',
                    ),
                    // Savaş müziği
                    _buildMusicCredit(
                      'Savaş Kategorisi Müziği',
                      'Zefz - Orchestral Epic Fantasy Music',
                      'Savaş Senaryosu',
                    ),
                    // Bilim Kurgu müziği
                    _buildMusicCredit(
                      'Bilim Kurgu Kategorisi Müziği',
                      'Ted Kerr - Sci-Fi Ambient - Crashed Ship',
                      'Bilim Kurgu',
                    ),
                    // Fantastik müziği
                    _buildMusicCredit(
                      'Fantastik Kategorisi Müziği',
                      'HitCtrl - Misty Mountains',
                      'Fantastik Senaryosu',
                    ),
                    // Tarihi müziği
                    _buildMusicCredit(
                      'Tarihi Kategorisi Müziği',
                      'TAD - Anti Entity',
                      'Tarih Senaryosu',
                    ),
                    // Kıyamet müziği
                    _buildMusicCredit(
                      'Kıyamet Sonrası Kategorisi Müziği',
                      'Trevor Lentz - The Void',
                      'Kıyamet Senaryosu',
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Ses Efektleri
                    _buildSection(
                      _languageService.getLocalizedText('Ses Efektleri', 'Sound Effects'),
                      '',
                    ),
                    const SizedBox(height: 20),
                    
                    _buildMusicCredit(
                      'Buton Tıklama Sesi',
                      'Ses Efekti Sahibi',
                      'Kaynak bilgisi',
                    ),
                    
                    _buildMusicCredit(
                      'Mesaj Gönderme Sesi',
                      'Ses Efekti Sahibi',
                      'Kaynak bilgisi',
                    ),
                    
                    _buildMusicCredit(
                      'AI Yanıt Sesi',
                      'Ses Efekti Sahibi',
                      'Kaynak bilgisi',
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Teknolojiler
                    _buildSection(
                      _languageService.getLocalizedText('Teknolojiler', 'Technologies'),
                      '',
                    ),
                    const SizedBox(height: 20),
                    
                    _buildCredit('Flutter', 'Google'),
                    _buildCredit('Dart', 'Google'),
                    _buildCredit('Gemini AI', 'Google'),
                    _buildCredit('AudioPlayers', 'Flutter Community'),
                    
                    const SizedBox(height: 40),
                    
                    // Teşekkürler
                    _buildSection(
                      _languageService.getLocalizedText('Teşekkürler', 'Thanks'),
                      '',
                    ),
                    const SizedBox(height: 20),
                    
                    _buildCredit('Flutter Community', ''),
                    _buildCredit('Google Fonts', ''),
                    _buildCredit('Open Source Contributors', ''),
                    
                    const SizedBox(height: 60),
                    
                    // Telif hakkı
                    _buildCopyright(),
                    
                    const SizedBox(height: 100), // Bitiş boşluğu
                  ],
                ),
              ),
            ),
          ),
          
          // Üst ve alt gradyan maskeleri
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.merriweather(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 10,
            color: Colors.purple.withOpacity(0.5),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSection(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade300,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildMusicCredit(String title, String composer, String source) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.sourceSans3(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            composer,
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
          if (source.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              source,
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCredit(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return Column(
      children: [
        Text(
          '© 2024 Ali Genç Türk',
          style: GoogleFonts.sourceSans3(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _languageService.getLocalizedText(
            'Tüm hakları saklıdır',
            'All rights reserved',
          ),
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 