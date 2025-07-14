import 'package:flutter/material.dart';
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(),
            tooltip: _languageService.settings,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade100,
              Colors.indigo.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başlık
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        size: 60,
                        color: Colors.deepPurple.shade600,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _languageService.getLocalizedText(
                          'Metin Tabanlı RPG Oyunu',
                          'Text-Based RPG Game',
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _languageService.categorySelectionSubtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Kategori butonları
                ...GameCategory.values.map((category) => _buildCategoryButton(
                  context,
                  category,
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kategori butonu oluşturur
  Widget _buildCategoryButton(BuildContext context, GameCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: () => _onCategorySelected(context, category),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getCategoryColor(category),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: Colors.black26,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 30,
            ),
            const SizedBox(width: 15),
            Text(
              category.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kategori seçildiğinde çalışır
  void _onCategorySelected(BuildContext context, GameCategory category) {
    _logger.gameEvent('Kategori seçildi', {'category': category.key});
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryScreen(category: category),
      ),
    );
  }

  /// Ayarlar ekranını açar
  void _openSettings() async {
    _logger.gameEvent('Ayarlar ekranı açılıyor');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
    
    // Ayarlardan dönüldüğünde ekranı yenile
    if (result == true) {
      setState(() {});
    }
  }

  /// Kategoriye göre renk döndürür
  Color _getCategoryColor(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return Colors.red.shade600;
      case GameCategory.sciFi:
        return Colors.blue.shade600;
      case GameCategory.history:
        return Colors.brown.shade600;
      case GameCategory.fantasy:
        return Colors.purple.shade600;
    }
  }

  /// Kategoriye göre ikon döndürür
  IconData _getCategoryIcon(GameCategory category) {
    switch (category) {
      case GameCategory.war:
        return Icons.military_tech;
      case GameCategory.sciFi:
        return Icons.rocket_launch;
      case GameCategory.history:
        return Icons.account_balance;
      case GameCategory.fantasy:
        return Icons.castle;
    }
  }
} 