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

enum _IntroStep { initial, welcome, subtitle, categories, finished }

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late final LoggerService _logger;
  late final LanguageService _languageService;
  
  _IntroStep _introStep = _IntroStep.initial;
  int _visibleCategoryIndex = -1;
  bool _isSkipped = false;

  @override
  void initState() {
    super.initState();
    _logger = LoggerService();
    _languageService = LanguageService();
    _startIntroAnimation();
  }

  void _startIntroAnimation() {
    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _introStep = _IntroStep.welcome);
    });
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _introStep = _IntroStep.subtitle);
    });
    Timer(const Duration(milliseconds: 4000), () {
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
      _introStep = _IntroStep.finished;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.categorySelectionTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context),
            tooltip: _languageService.settings,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildIntroTexts(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildCategoryGrid(),
            ),
            _buildIntroControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroTexts() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _introStep.index >= _IntroStep.welcome.index ? 1.0 : 0.0,
      child: Column(
        children: [
          Text(
            _languageService.getLocalizedText('Hoş geldin Maceracı', 'Welcome Adventurer'),
            style: GoogleFonts.merriweather(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: _introStep.index >= _IntroStep.subtitle.index ? 1.0 : 0.0,
            child: _introStep.index >= _IntroStep.subtitle.index 
              ? AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      _languageService.categorySelectionSubtitle,
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 50),
                      textStyle: GoogleFonts.sourceSans3(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                )
              : Text( // Placeholder for size calculation
                  _languageService.categorySelectionSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(fontSize: 18, color: Colors.transparent),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _introStep.index >= _IntroStep.categories.index ? 1.0 : 0.0,
      child: AnimationLimiter(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
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
              columnCount: 2,
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
      ),
    );
  }

  Widget _buildIntroControls() {
    final showControls = _introStep == _IntroStep.categories && !_isSkipped;
    final isLastCategory = _visibleCategoryIndex == GameCategory.values.length - 1;
    final isIndexValid = _visibleCategoryIndex >= 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: showControls ? 200 : 0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              AnimatedSwitcher(
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
              const SizedBox(height: 20),
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
          margin: const EdgeInsets.only(bottom: 20),
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
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 15),
              Text(
                LanguageService().getCategoryName(widget.category.key),
                style: GoogleFonts.merriweather(
                  fontSize: 22,
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