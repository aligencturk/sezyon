import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_category.dart';
import '../services/language_service.dart';
import 'story_screen_new.dart';

class CharacterNameScreen extends StatefulWidget {
  final GameCategory category;

  const CharacterNameScreen({super.key, required this.category});

  @override
  State<CharacterNameScreen> createState() => _CharacterNameScreenState();
}

class _CharacterNameScreenState extends State<CharacterNameScreen> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  final _languageService = LanguageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Otomatik odaklanma
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startStory() {
    final characterName = _nameController.text.trim();
    if (characterName.isEmpty) {
      _showErrorDialog(
        _languageService.getLocalizedText(
          'Lütfen karakter adınızı girin.',
          'Please enter your character name.',
        ),
      );
      return;
    }

    if (characterName.length < 2) {
      _showErrorDialog(
        _languageService.getLocalizedText(
          'Karakter adı en az 2 karakter olmalıdır.',
          'Character name must be at least 2 characters.',
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StoryScreenNew(
          category: widget.category,
          characterName: characterName,
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_languageService.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_languageService.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _languageService.getLocalizedText('Karakter Adı', 'Character Name'),
          style: GoogleFonts.merriweather(fontSize: 20),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
      ),
      body: Stack(
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
                  // Kategori ikonu ve adı
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.category.displayName,
                          style: GoogleFonts.merriweather(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.category.getDescription(
                            _languageService.currentLanguageCode,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Karakter adı girişi
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _languageService.getLocalizedText(
                            'Karakterinizin adı nedir?',
                            'What is your character\'s name?',
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          enabled: !_isLoading,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _startStory(),
                          style: GoogleFonts.sourceSans3(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: _languageService.getLocalizedText(
                              'Örn: Ahmet, Ayşe, Kemal...',
                              'e.g: John, Sarah, Alex...',
                            ),
                            hintStyle: GoogleFonts.sourceSans3(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _startStory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _languageService.getLocalizedText(
                                      'Hikayeyi Başlat',
                                      'Start Story',
                                    ),
                                    style: GoogleFonts.sourceSans3(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // İpucu metni
                  Text(
                    _languageService.getLocalizedText(
                      'Bu isim hikaye boyunca kullanılacak ve karakterinizi kişiselleştirecektir.',
                      'This name will be used throughout the story and personalize your character.',
                    ),
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case GameCategory.war:
        return Icons.military_tech;
      case GameCategory.fantasy:
        return Icons.auto_stories;
      case GameCategory.sciFi:
        return Icons.rocket_launch;
      case GameCategory.mystery:
        return Icons.search;
      case GameCategory.historical:
        return Icons.account_balance;
      case GameCategory.apocalypse:
        return Icons.warning;
    }
  }
}
