import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sezyon/models/game_category.dart';
import 'package:sezyon/screens/settings_screen.dart';
import 'package:sezyon/screens/story_screen.dart';
import 'package:sezyon/screens/credits_screen.dart';
import 'package:sezyon/services/language_service.dart';
import 'package:sezyon/services/logger_service.dart';
import 'package:sezyon/services/audio_service.dart';
import 'package:sezyon/utils/custom_page_route.dart';

/// Oyun kategorisi seçimi ekranı
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

enum _IntroStep {
  blackScreen,
  welcomeTyping,
  welcomeDone,
  subtitleTyping,
  animatingUp,
  categories,
  finished,
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late final LoggerService _logger;
  late final LanguageService _languageService;
  final AudioService _audioService = AudioService();

  _IntroStep _introStep = _IntroStep.blackScreen;
  int _visibleCategoryIndex = -1;
  bool _isSkipped = false;
  bool _showWelcome = false;
  bool _showSubtitle = false;
  bool _isTransitioning = false;
  bool _showMainScreen = false;

  @override
  void initState() {
    super.initState();
    _logger = LoggerService();
    _languageService = LanguageService();
    _startIntroAnimation();

    // Eğer intro atlandıysa veya tamamlandıysa ana ekranı göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_introStep == _IntroStep.finished || _isSkipped) {
        setState(() => _showMainScreen = true);
      }
    });
  }

  void _startIntroAnimation() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _introStep = _IntroStep.welcomeTyping;
        _showWelcome = true;
      });
    });
  }

  void _onWelcomeFinished() {
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _introStep = _IntroStep.subtitleTyping;
        _showSubtitle = true;
      });
    });
  }

  void _onSubtitleFinished() {
    setState(() => _introStep = _IntroStep.animatingUp);
    Timer(const Duration(milliseconds: 800), () {
      // Animasyon süresi
      if (!mounted) return;
      setState(() {
        _introStep = _IntroStep.categories;
        _visibleCategoryIndex = 0;
      });
    });
  }

  void _proceedIntro() {
    if (_visibleCategoryIndex < GameCategory.values.length - 1) {
      setState(() => _visibleCategoryIndex++);
    } else {
      _finishIntroWithAnimation();
    }
  }

  void _skipIntro() {
    _finishIntroWithAnimation();
  }

  void _finishIntroWithAnimation() {
    // Geçiş animasyonu başlat
    setState(() => _isTransitioning = true);

    // Kararma animasyonunun bitmesini bekle
    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      setState(() {
        _isSkipped = true;
        _showWelcome = true;
        _showSubtitle = true;
        _introStep = _IntroStep.finished;
      });

      // Kararma bittikten sonra ana ekran öğelerini animasyonlu göster
      Timer(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        setState(() {
          _isTransitioning = false; // Kararma bitiyor
          _showMainScreen = true; // Ana ekran öğeleri animasyonlu geliyor
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _introStep.index >= _IntroStep.finished.index
          ? AppBar(
              title: AnimatedOpacity(
                opacity: _showMainScreen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Text(_languageService.categorySelectionTitle),
              ),
              actions: [
                AnimatedOpacity(
                  opacity: _showMainScreen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _openCredits(context),
                    tooltip: _languageService.getLocalizedText(
                      'Jenerik',
                      'Credits',
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _showMainScreen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => _openSettings(context),
                    tooltip: _languageService.settings,
                  ),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          // Mevcut tüm içerik
          Stack(
            children: [
              _buildAnimatedTexts(),
              AnimatedOpacity(
                opacity: _introStep.index >= _IntroStep.categories.index
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Expanded(child: _buildCategoryIntroView()),
                    _buildIntroControls(),
                  ],
                ),
              ),
            ],
          ),
          // Kararma efekti için üst katman
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _isTransitioning ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTexts() {
    return AnimatedAlign(
      alignment: _introStep.index >= _IntroStep.animatingUp.index
          ? Alignment.topCenter
          : Alignment.center,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16.0, // sol
          _introStep.index >= _IntroStep.animatingUp.index
              ? 60.0
              : 0.0, // üst (koşullu)
          16.0, // sağ
          0.0, // alt
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showWelcome)
              AnimatedTextKit(
                key: const ValueKey('welcome'),
                isRepeatingAnimation: false,
                onFinished: _onWelcomeFinished,
                animatedTexts: [
                  TypewriterAnimatedText(
                    _languageService.getLocalizedText(
                      'Hoş geldin Maceracı',
                      'Welcome Adventurer',
                    ),
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.merriweather(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 10),
            if (_showSubtitle)
              AnimatedTextKit(
                key: const ValueKey('subtitle'),
                isRepeatingAnimation: false,
                onFinished: _onSubtitleFinished,
                animatedTexts: [
                  TypewriterAnimatedText(
                    _languageService.categorySelectionSubtitle,
                    textAlign: TextAlign.center,
                    speed: const Duration(milliseconds: 50),
                    textStyle: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIntroView() {
    // Tanıtım bittiyse veya atlandıysa tüm ızgarayı göster
    if (_introStep == _IntroStep.finished || _isSkipped) {
      return _buildFullCategoryGrid();
    }

    // Tanıtım devam ediyorsa, tek bir kategori göster
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        final offsetAnimation =
            Tween<Offset>(
              begin: const Offset(1.5, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            );

        return ClipRect(
          child: SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child:
          _introStep.index >= _IntroStep.categories.index &&
              _visibleCategoryIndex != -1
          ? CategoryCard(
              key: ValueKey<int>(
                _visibleCategoryIndex,
              ), // Animasyonun tetiklenmesi için anahtar
              category: GameCategory.values[_visibleCategoryIndex],
              onTap: () {
                // Intro sırasında tıklamayı engelle, sadece bitince aktif olsun
                if (_introStep == _IntroStep.finished || _isSkipped) {
                  _onCategorySelected(
                    context,
                    GameCategory.values[_visibleCategoryIndex],
                  );
                }
              },
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFullCategoryGrid() {
    return AnimatedOpacity(
      opacity: _showMainScreen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800), // Yumuşak fade-in
      curve: Curves.easeInOut,
      child: AnimationLimiter(
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            childAspectRatio: 0.9,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: GameCategory.values.length,
          itemBuilder: (context, index) {
            final category = GameCategory.values[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600), // Biraz daha hızlı
              columnCount: (MediaQuery.of(context).size.width / 160).floor(),
              child: SlideAnimation(
                verticalOffset: 50.0, // Yukarıdan aşağıya kayma
                child: FadeInAnimation(
                  child: CategoryCard(
                    category: category,
                    onTap: () => _onCategorySelected(context, category),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroControls() {
    final showControls = _introStep == _IntroStep.categories && !_isSkipped;
    final isLastCategory =
        _visibleCategoryIndex == GameCategory.values.length - 1;
    final isIndexValid = _visibleCategoryIndex >= 0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: showControls ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !showControls,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    isIndexValid
                        ? GameCategory.values[_visibleCategoryIndex]
                              .getDescription(
                                _languageService.currentLanguageCode,
                              )
                        : '',
                    key: ValueKey<int>(_visibleCategoryIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _skipIntro,
                    child: Text(
                      _languageService.getLocalizedText('Atla', 'Skip'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _proceedIntro,
                    child: Text(
                      isLastCategory
                          ? _languageService.getLocalizedText('Bitir', 'Finish')
                          : _languageService.getLocalizedText(
                              'Devam Et',
                              'Continue',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(BuildContext context, GameCategory category) {
    if (_isTransitioning) return; // Zaten bir geçiş başladıysa tekrar tetikleme

    _logger.gameEvent('Kategori seçildi ve hikaye ekranına yönlendiriliyor', {
      'category': category.name,
    });

    // Kategori seçim sesi - mevcut dosya yoksa kaldır
    // _audioService.playSoundEffect('audio/button_click.wav');

    setState(() => _isTransitioning = true);

    // Kararma animasyonunun bitmesini bekle
    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      Navigator.push(
        context,
        FadePageRoute(
          child: StoryScreen(category: category),
          transitionDuration: const Duration(
            milliseconds: 800,
          ), // Yeni ekran daha yavaş açılsın
        ),
      ).then((_) {
        // Kullanıcı sohbet ekranından geri geldiğinde kararmayı kaldır
        if (mounted) {
          setState(() => _isTransitioning = false);
          // Ana menü müziğine yumuşak geçiş
          _audioService.playMainMenuMusic();
        }
      });
    });
  }

  void _openCredits(BuildContext context) async {
    _logger.gameEvent('Credits ekranı açılıyor');
    // Credits buton tıklama sesi - mevcut dosya yoksa kaldır
    // _audioService.playSoundEffect('audio/button_click.wav');
    await Navigator.push(context, FadePageRoute(child: const CreditsScreen()));
  }

  void _openSettings(BuildContext context) async {
    _logger.gameEvent('Ayarlar ekranı açılıyor');
    await Navigator.push(
      context,
      FadePageRoute(
        child: SettingsScreen(onLanguageChanged: () => setState(() {})),
      ),
    );
  }

  @override
  void dispose() {
    // Audio servisini sıfırla (hot restart için)
    _audioService.reset();
    super.dispose();
  }
}

class CategoryCard extends StatefulWidget {
  final GameCategory category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lottiePath = _getLottiePath(widget.category);

    // Tarihi kategorisi için animasyonu büyütmek adına bir widget oluştur
    Widget lottieWidget = Lottie.asset(lottiePath, fit: BoxFit.contain);

    if (widget.category == GameCategory.historical) {
      lottieWidget = Transform.scale(
        scale: 0.8, // Ölçeği daha da artırdık
        child: lottieWidget,
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      lottieWidget,
                      // Atmosfer için hafif bir gradyan
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        LanguageService().getCategoryName(widget.category.key),
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLottiePath(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return 'assets/images/war.json';
      case GameCategory.sciFi:
        return 'assets/images/scifi.json';
      case GameCategory.fantasy:
        return 'assets/images/fantasy.json';
      case GameCategory.mystery:
        return 'assets/images/mystery.json';
      case GameCategory.historical:
        return 'assets/images/history.json';
      case GameCategory.apocalypse:
        return 'assets/images/apocalypse.json';
    }
  }
}
