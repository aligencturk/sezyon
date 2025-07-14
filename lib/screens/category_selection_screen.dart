import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_category.dart';
import '../services/language_service.dart';
import '../services/logger_service.dart';
import 'story_screen.dart';
import 'settings_screen.dart';

/// Oyun kategorisi seçimi ekranı
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final LanguageService _languageService = LanguageService();
  final LoggerService _logger = LoggerService();

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _languageService.getLocalizedText('Hoş Geldin, Maceracı', 'Welcome, Adventurer'),
                style: GoogleFonts.cinzel(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _languageService.categorySelectionSubtitle,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 30),
              ...GameCategory.values
                  .map((category) => CategoryCard(
                        category: category,
                        onTap: () => _onCategorySelected(context, category),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(BuildContext context, GameCategory category) {
    _logger.gameEvent('Kategori seçildi', {'category': category.key});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryScreen(category: category),
      ),
    );
  }

  void _openSettings(BuildContext context) async {
    _logger.gameEvent('Ayarlar ekranı açılıyor');
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SettingsScreen(onLanguageChanged: () => setState(() {}))),
    );
  }
}

/// Kategori kartı widget'ı
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
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  widget.category.displayName,
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getCategoryStyle(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return (Icons.shield, const Color(0xffc0392b));
      case GameCategory.sciFi:
        return (Icons.rocket_launch, const Color(0xff2980b9));
      case GameCategory.fantasy:
        return (Icons.castle, const Color(0xff8e44ad));
      case GameCategory.mystery:
        return (Icons.visibility, const Color(0xff2c3e50));
      case GameCategory.historical:
        return (Icons.account_balance, const Color(0xffd35400));
      case GameCategory.apocalypse:
        return (Icons.landscape, const Color(0xff7f8c8d));
    }
  }
} 