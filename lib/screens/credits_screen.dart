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

  final GlobalKey _creditsColumnKey = GlobalKey();
  
  late AnimationController _animationController;
  late AnimationController _finalAnimationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _scrollAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  double _creditsHeight = 0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
    );
    
    _finalAnimationController = AnimationController(
      duration: const Duration(seconds: 4), 
      vsync: this,
    );
    
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _finalAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3, 
      end: 1.0,   
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndStartAnimation();
    });
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _finalAnimationController.forward();
        });
      }
    });
    
    _finalAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _glowAnimationController.repeat(reverse: true); 
        });
      }
    });
  }

  void _calculateAndStartAnimation() {
    if (!mounted) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final RenderBox? creditsRenderBox = _creditsColumnKey.currentContext?.findRenderObject() as RenderBox?;
    final creditsHeight = creditsRenderBox?.size.height ?? screenHeight * 2; 

    if (creditsHeight > 0) {
      setState(() {
        _creditsHeight = creditsHeight;
      });

      const scrollSpeed = 90.0; 
      final totalDistance = screenHeight + _creditsHeight;
      final durationInSeconds = totalDistance / scrollSpeed;

      _animationController.duration = Duration(seconds: durationInSeconds.round());
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _finalAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitleStyle = GoogleFonts.merriweather(fontSize: 20);
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
          
          AnimatedBuilder(
            animation: _scrollAnimation,
            builder: (context, child) {
              if (_creditsHeight == 0) {
                return Opacity(
                  opacity: 0,
                  child: child,
                );
              }

              final totalDistance = screenHeight + _creditsHeight;
              final offset = screenHeight - (_scrollAnimation.value * totalDistance);
              
              return Transform.translate(
                offset: Offset(0, offset),
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                key: _creditsColumnKey,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.3),
                  
                  _buildTitle('Sezyon'),
                  const SizedBox(height: 50),
                  
                  _buildSection(
                    _languageService.getLocalizedText('Geliştirici', 'Developer'),
                    'Ali Talip Gençtürk',
                  ),
                  const SizedBox(height: 40),
                  
                  _buildSection(
                    _languageService.getLocalizedText('Müzikler', 'Music'),
                    '',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildMusicCredit(
                    'Ana Menü Müziği',
                    'lucafrancini - Atmospheric Glitch',
                    'Ana Menü',
                  ),
                  _buildMusicCredit(
                    'Gizem Kategorisi Müziği',
                    'Alexandr Zhelanov - Mystery Manor',
                    'Gizem Senaryosu',
                  ),
                  _buildMusicCredit(
                    'Savaş Kategorisi Müziği',
                    'Zefz - Orchestral Epic Fantasy Music',
                    'Savaş Senaryosu',
                  ),
                  _buildMusicCredit(
                    'Bilim Kurgu Kategorisi Müziği',
                    'Ted Kerr - Sci-Fi Ambient - Crashed Ship',
                    'Bilim Kurgu',
                  ),
                  _buildMusicCredit(
                    'Fantastik Kategorisi Müziği',
                    'HitCtrl - Misty Mountains',
                    'Fantastik Senaryo',
                  ),
                  _buildMusicCredit(
                    'Tarihi Kategorisi Müziği',
                    'TAD - Anti Entity',
                    'Tarihi Senaryo',
                  ),
                  _buildMusicCredit(
                    'Kıyamet Sonrası Kategorisi Müziği',
                    'Trevor Lentz - The Void',
                    'Kıyamet Senaryosu',
                  ),
                  
                  SizedBox(height: screenHeight),
                ],
              ),
            ),
          ),
          
          AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
            builder: (context, child) {
              if (_finalAnimationController.isAnimating || _finalAnimationController.isCompleted) {
                return Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlowingTitle('Sezyon', _glowAnimation.value),
                
                const SizedBox(height: 20),
                
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

  Widget _buildGlowingTitle(String title, double glowIntensity) {
    return Text(
      title,
      style: GoogleFonts.merriweather(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            offset: const Offset(0, 4),
            blurRadius: 15 * glowIntensity, // Parlama yoğunluğu
            color: Colors.purple.withOpacity(0.7 * glowIntensity),
          ),
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 8 * glowIntensity, // Parlama yoğunluğu
            color: Colors.purple.withOpacity(0.5 * glowIntensity),
          ),
          // Ekstra parlama efekti
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 25 * glowIntensity,
            color: Colors.purple.withOpacity(0.3 * glowIntensity),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
} 