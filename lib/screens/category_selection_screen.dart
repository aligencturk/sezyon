import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sezyon/models/game_category.dart';
import 'package:sezyon/screens/settings_screen.dart';
import 'package:sezyon/screens/story_screen.dart';
import 'package:sezyon/services/language_service.dart';
import 'package:sezyon/services/logger_service.dart';
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
  finished
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late final LoggerService _logger;
  late final LanguageService _languageService;
  
  _IntroStep _introStep = _IntroStep.blackScreen;
  int _visibleCategoryIndex = -1;
  bool _isSkipped = false;
  bool _showWelcome = false;
  bool _showSubtitle = false;

  @override
  void initState() {
    super.initState();
    _logger = LoggerService();
    _languageService = LanguageService();
    _startIntroAnimation();
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
    Timer(const Duration(milliseconds: 800), () { // Animasyon süresi
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
      setState(() => _introStep = _IntroStep.finished);
    }
  }

  void _skipIntro() {
    setState(() {
      _isSkipped = true;
      _showWelcome = true;
      _showSubtitle = true;
      _introStep = _IntroStep.finished;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _introStep.index >= _IntroStep.finished.index
          ? AppBar(
              title: Text(_languageService.categorySelectionTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _openSettings(context),
                  tooltip: _languageService.settings,
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          _buildAnimatedTexts(),
          AnimatedOpacity(
            opacity: _introStep.index >= _IntroStep.categories.index ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Expanded(child: _buildCategoryGrid()),
                _buildIntroControls(),
              ],
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
        padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
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
                    _languageService.getLocalizedText('Hoş geldin Maceracı', 'Welcome Adventurer'),
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.merriweather(fontSize: 32, fontWeight: FontWeight.bold),
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
                    textStyle: GoogleFonts.sourceSans3(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160, // Genişliği daha da küçülttük
          childAspectRatio: 0.9,  // Oranı daha kareye yakın yaptık
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: _isSkipped
            ? GameCategory.values.length
            : _introStep.index >= _IntroStep.categories.index
                ? _visibleCategoryIndex + 1
                : 0,
        itemBuilder: (context, index) {
          if (index >= GameCategory.values.length) return const SizedBox.shrink();
          final category = GameCategory.values[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 400),
            columnCount: (MediaQuery.of(context).size.width / 160).floor(), // Genişlikle uyumlu hale getirdik
            child: ScaleAnimation(
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
    );
  }

  Widget _buildIntroControls() {
    final showControls = _introStep == _IntroStep.categories && !_isSkipped;
    final isLastCategory = _visibleCategoryIndex == GameCategory.values.length - 1;
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
                            .getDescription(_languageService.currentLanguageCode)
                        : '',
                    key: ValueKey<int>(_visibleCategoryIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _skipIntro,
                    child: Text(_languageService.getLocalizedText('Atla', 'Skip')),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _proceedIntro,
                    child: Text(isLastCategory
                        ? _languageService.getLocalizedText('Bitir', 'Finish')
                        : _languageService.getLocalizedText('Devam Et', 'Continue')),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(BuildContext context, GameCategory category) {
    _logger.gameEvent('Kategori seçildi ve hikaye ekranına yönlendiriliyor',
        {'category': category.name});
    Navigator.push(
      context,
      FadePageRoute(
        child: StoryScreen(category: category),
      ),
    );
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
}

class CategoryCard extends StatefulWidget {
  final GameCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getCategoryStyle(widget.category);

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
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.7),
                color.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: 40, color: Colors.white), // İkon boyutunu küçülttük
              const SizedBox(height: 12),
              Text(
                LanguageService().getCategoryName(widget.category.key),
                style: GoogleFonts.merriweather(
                  fontSize: 18, // Yazı tipi boyutunu küçülttük
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getCategoryStyle(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return (Icons.shield, Colors.red.shade800);
      case GameCategory.sciFi:
        return (Icons.rocket_launch, Colors.blue.shade800);
      case GameCategory.fantasy:
        return (Icons.auto_stories, Colors.purple.shade800);
      case GameCategory.mystery:
        return (Icons.question_mark_sharp, Colors.grey.shade800);
      case GameCategory.historical:
        return (Icons.fort, Colors.amber.shade900);
      case GameCategory.apocalypse:
        return (Icons.warning, Colors.green.shade900);
    }
  }
} 