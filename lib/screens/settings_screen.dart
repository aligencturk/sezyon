import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/logger_service.dart';

/// Ayarlar ekranı
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageService _languageService = LanguageService();
  final LoggerService _logger = LoggerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildLanguageSection(),
            const SizedBox(height: 20),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  /// Dil seçimi bölümü
  Widget _buildLanguageSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Colors.deepPurple.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  _languageService.language,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLanguageOptions(),
          ],
        ),
      ),
    );
  }

  /// Dil seçenekleri
  Widget _buildLanguageOptions() {
    return Column(
      children: AppLanguage.values.map((language) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _changeLanguage(language),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _languageService.currentLanguage == language
                    ? Colors.deepPurple.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _languageService.currentLanguage == language
                      ? Colors.deepPurple.shade600
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      language.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _languageService.currentLanguage == language
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _languageService.currentLanguage == language
                            ? Colors.deepPurple.shade800
                            : Colors.black87,
                      ),
                    ),
                  ),
                  if (_languageService.currentLanguage == language)
                    Icon(
                      Icons.check_circle,
                      color: Colors.deepPurple.shade600,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Bilgi bölümü
  Widget _buildInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  _languageService.getLocalizedText('Bilgi', 'Information'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              Icons.auto_stories,
              _languageService.getLocalizedText('Oyun Türü', 'Game Type'),
              _languageService.getLocalizedText(
                'Metin Tabanlı RPG',
                'Text-Based RPG',
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.smart_toy,
              _languageService.getLocalizedText('AI Modeli', 'AI Model'),
              'Gemini 2.0 Flash',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.translate,
              _languageService.getLocalizedText('Desteklenen Diller', 'Supported Languages'),
              _languageService.getLocalizedText(
                'Türkçe, İngilizce',
                'Turkish, English',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bilgi öğesi
  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dil değiştirme
  Future<void> _changeLanguage(AppLanguage language) async {
    if (_languageService.currentLanguage == language) return;

    _logger.gameEvent('Dil değiştiriliyor', {
      'from': _languageService.currentLanguage.displayName,
      'to': language.displayName,
    });

    final success = await _languageService.setLanguage(language);
    
    if (success && mounted) {
      setState(() {});
      
      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageService.getLocalizedText(
              'Dil başarıyla değiştirildi',
              'Language changed successfully',
            ),
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
        ),
      );

      _logger.gameEvent('Dil başarıyla değiştirildi', {
        'newLanguage': language.displayName,
      });
    } else if (mounted) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageService.getLocalizedText(
              'Dil değiştirilirken hata oluştu',
              'Error occurred while changing language',
            ),
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 2),
        ),
      );

      _logger.error('Dil değiştirme başarısız', {'targetLanguage': language.displayName});
    }
  }
} 