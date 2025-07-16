import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/language_service.dart';
import '../services/logger_service.dart';
import '../services/audio_service.dart';

/// Ayarlar ekranı
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onLanguageChanged});
  final VoidCallback onLanguageChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageService _languageService = LanguageService();
  final LoggerService _logger = LoggerService();
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle(
            context,
            icon: Icons.language,
            title: _languageService.language,
          ),
          const SizedBox(height: 10),
          ...AppLanguage.values.map((language) => _buildLanguageOption(language)),
          const SizedBox(height: 30),
          _buildSectionTitle(
            context,
            icon: Icons.music_note,
            title: _languageService.getLocalizedText('Ses Ayarları', 'Audio Settings'),
          ),
          const SizedBox(height: 10),
          _buildAudioSettingsCard(),
          const SizedBox(height: 30),
          _buildSectionTitle(
            context,
            icon: Icons.info_outline,
            title: _languageService.getLocalizedText('Bilgi', 'Information'),
          ),
          const SizedBox(height: 10),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, {required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(AppLanguage language) {
    bool isSelected = _languageService.currentLanguage == language;
    return GestureDetector(
      onTap: () => _changeLanguage(language),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                language.displayName,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(isSelected ? 1.0 : 0.8),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildAudioToggle(
            Icons.music_note,
            _languageService.getLocalizedText('Arka Plan Müziği', 'Background Music'),
            _audioService.isMusicEnabled,
            (value) => _toggleMusic(value),
          ),
          const SizedBox(height: 15),
          _buildAudioToggle(
            Icons.volume_up,
            _languageService.getLocalizedText('Ses Efektleri', 'Sound Effects'),
            _audioService.isSoundEnabled,
            (value) => _toggleSound(value),
          ),
          const SizedBox(height: 20),
          _buildVolumeSlider(
            Icons.music_note,
            _languageService.getLocalizedText('Müzik Ses Seviyesi', 'Music Volume'),
            _audioService.musicVolume,
            (value) => _setMusicVolume(value),
          ),
          const SizedBox(height: 15),
          _buildVolumeSlider(
            Icons.volume_up,
            _languageService.getLocalizedText('Ses Efekti Seviyesi', 'Sound Effects Volume'),
            _audioService.soundVolume,
            (value) => _setSoundVolume(value),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildInfoItem(
            Icons.smart_toy,
            _languageService.getLocalizedText('AI Modeli', 'AI Model'),
            'Gemini 2.0 Flash',
          ),
          const Divider(height: 30),
          _buildInfoItem(
            Icons.developer_mode,
            _languageService.getLocalizedText('Geliştirici', 'Developer'),
            'Ali Genç Türk',
          ),
        ],
      ),
    );
  }

  Widget _buildAudioToggle(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(IconData icon, String title, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Colors.grey.shade700,
        ),
      ],
    );
  }

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

  /// Müziği aç/kapat
  Future<void> _toggleMusic(bool value) async {
    // Buton tıklama sesi - mevcut dosya yoksa kaldır
    // _audioService.playSoundEffect('audio/button_click.wav');
    
    await _audioService.toggleMusic();
    setState(() {});
    
    _logger.gameEvent('Müzik ayarı değiştirildi', {
      'enabled': _audioService.isMusicEnabled,
    });
  }

  /// Ses efektlerini aç/kapat
  void _toggleSound(bool value) {
    // Buton tıklama sesi (ses efektleri kapalıysa çalmayacak) - mevcut dosya yoksa kaldır
    // if (_audioService.isSoundEnabled) {
    //   _audioService.playSoundEffect('audio/button_click.wav');
    // }
    
    _audioService.toggleSound();
    setState(() {});
    
    _logger.gameEvent('Ses efekti ayarı değiştirildi', {
      'enabled': _audioService.isSoundEnabled,
    });
  }

  /// Müzik ses seviyesini ayarla
  Future<void> _setMusicVolume(double value) async {
    await _audioService.setMusicVolume(value);
    setState(() {});
    
    _logger.gameEvent('Müzik ses seviyesi değiştirildi', {
      'volume': value,
    });
  }

  /// Ses efekti ses seviyesini ayarla
  Future<void> _setSoundVolume(double value) async {
    await _audioService.setSoundVolume(value);
    setState(() {});
    
    _logger.gameEvent('Ses efekti ses seviyesi değiştirildi', {
      'volume': value,
    });
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
      widget.onLanguageChanged();
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