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

class _CreditsScreenState extends State<CreditsScreen> with TickerProviderStateMixin {
  final LanguageService _languageService = LanguageService();
  final AudioService _audioService = AudioService();
  
  late AnimationController _animationController;
  late Animation<double> _scrollAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    
    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    // Animasyonu hemen başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitleStyle = GoogleFonts.merriweather(fontSize: 20);
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _languageService.getLocalizedText('Jenerik', 'Credits'),
          style: appBarTitleStyle,
        ),
        backgroundColor: Colors.black.withOpacity(0.95),
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
          AnimatedBuilder(
            animation: _scrollAnimation,
            builder: (context, child) {
              // Başlangıçta ekranın altında, bitişte ekranın üstünde olacak şekilde
              final offset = screenHeight * (1.0 - _scrollAnimation.value * 3.0);
              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.3),
                      
                      // Oyun başlığı
                      _buildTitle('Sezyon'),
                      const SizedBox(height: 50),
                      
                      // Geliştirici
                      _buildSection(
                        _languageService.getLocalizedText('Geliştirici', 'Developer'),
                        'Ali Talip Gençtürk',
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
                        'Fantastik Senaryo',
                      ),
                      // Tarihi müziği
                      _buildMusicCredit(
                        'Tarihi Kategorisi Müziği',
                        'TAD - Anti Entity',
                        'Tarihi Senaryo',
                      ),
                      // Kıyamet müziği
                      _buildMusicCredit(
                        'Kıyamet Sonrası Kategorisi Müziği',
                        'Trevor Lentz - The Void',
                        'Kıyamet Senaryosu',
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Son Sezyon yazısı (splash ekranındaki gibi)
                      _buildFinalTitle('Sezyon'),
                      
                      const SizedBox(height: 20),
                      
                      // Copyright yazısı (Sezyon yazısının altında)
                      Text(
                        '© 2025 Ali Talip Gençtürk',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tüm hakları saklıdır yazısı (Copyright yazısının altında)
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
                      
                      SizedBox(height: screenHeight * 1.5),
                    ],
                  ),
                ),
              );
            },
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
          '© 2025 Ali Talip Gençtürk',
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

  Widget _buildFinalTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.merriweather(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: Colors.purple.withOpacity(0.7),
          ),
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.purple.withOpacity(0.5),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
} 