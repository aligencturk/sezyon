import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:sezyon/services/logger_service.dart';

/// Müzik ve ses efektleri için servis sınıfı
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  final LoggerService _logger = LoggerService();

  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  double _musicVolume = 0.5;
  double _soundVolume = 0.7;
  bool _isAppInBackground = false;

  /// Müzik çalma durumu
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  double get musicVolume => _musicVolume;
  double get soundVolume => _soundVolume;

  /// Arka plan müziği çal
  Future<void> playBackgroundMusic(String musicPath) async {
    if (!_isMusicEnabled || _isAppInBackground) return;

    try {
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.setVolume(_musicVolume);
      await _backgroundMusicPlayer.play(AssetSource(musicPath));
      _logger.info('🎵 Arka plan müziği çalınıyor: $musicPath');
    } catch (e) {
      _logger.error('Müzik çalınırken hata oluştu', e);
    }
  }

  /// Kategori bazlı müzik çal (yumuşak geçiş ile)
  Future<void> playCategoryMusic(String categoryName) async {
    if (!_isMusicEnabled || _isAppInBackground) return;

    // Olası dosya adları ve uzantıları
    final fileCandidates = <String>[];
    final key = categoryName.toLowerCase();
    if (key == 'war') {
      fileCandidates.addAll(['audio/savas.ogg', 'audio/savas.OGG', 'audio/savaş.ogg', 'audio/savaş.OGG']);
    } else if (key == 'scifi') {
      fileCandidates.addAll(['audio/scifi.ogg', 'audio/ScıFı.ogg', 'audio/ScıFı.OGG', 'audio/Scifi.ogg', 'audio/scifi.mp3', 'audio/ScıFı.mp3']);
    } else if (key == 'fantasy') {
      fileCandidates.addAll(['audio/fantasy.ogg', 'audio/fantasy.mp3']);
    } else if (key == 'mystery') {
      fileCandidates.addAll(['audio/gizem.ogg', 'audio/gizem.mp3']);
    } else if (key == 'historical') {
      fileCandidates.addAll(['audio/tarihi.ogg', 'audio/history.ogg', 'audio/history.mp3']);
    } else if (key == 'apocalypse') {
      fileCandidates.addAll(['audio/kiyamet.ogg', 'audio/kiyamet.mp3']);
    } else {
      fileCandidates.add('audio/$key.ogg');
      fileCandidates.add('audio/$key.mp3');
    }

    bool played = false;
    for (final musicPath in fileCandidates) {
      try {
        await _fadeOutCurrentMusic();
        await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
        await _backgroundMusicPlayer.setVolume(0.0);
        await _backgroundMusicPlayer.play(AssetSource(musicPath));
        await _fadeInNewMusic();
        _logger.info('🎵 Kategori müziği başarıyla çalınıyor: $musicPath');
        played = true;
        break;
      } catch (e) {
        _logger.warning('Kategori müziği bulunamadı: $musicPath, hata: $e');
      }
    }
    if (!played) {
      _logger.warning('Kategoriye uygun müzik bulunamadı, ana menü müziğine dönülüyor');
      await playMainMenuMusic();
    }
  }

  /// Kategori adını Türkçe dosya adına çevir
  String _getTurkishFileName(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'war':
        return 'savaş';
      case 'scifi':
        return 'ScıFı';
      case 'fantasy':
        return 'fantasy';
      case 'mystery':
        return 'gizem';
      case 'historical':
        return 'tarihi';
      case 'apocalypse':
        return 'kıyamet';
      default:
        return categoryName.toLowerCase();
    }
  }

  /// Mevcut müziği yavaşça azalt
  Future<void> _fadeOutCurrentMusic() async {
    const fadeDuration = Duration(milliseconds: 1000);
    const steps = 20;
    const stepDuration = 1000 ~/ steps;
    
    for (int i = steps; i >= 0; i--) {
      final volume = (_musicVolume * i) / steps;
      await _backgroundMusicPlayer.setVolume(volume);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  /// Yeni müziği yavaşça artır
  Future<void> _fadeInNewMusic() async {
    const fadeDuration = Duration(milliseconds: 1000);
    const steps = 20;
    const stepDuration = 1000 ~/ steps;
    
    for (int i = 0; i <= steps; i++) {
      final volume = (_musicVolume * i) / steps;
      await _backgroundMusicPlayer.setVolume(volume);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  /// Arka plan müziğini durdur
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.stop();
      _logger.info('🔇 Arka plan müziği durduruldu');
    } catch (e) {
      _logger.error('Müzik durdurulurken hata oluştu', e);
    }
  }

  /// Arka plan müziğini duraklat
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.pause();
      _logger.info('⏸️ Arka plan müziği duraklatıldı');
    } catch (e) {
      _logger.error('Müzik duraklatılırken hata oluştu', e);
    }
  }

  /// Ana menü müziğine yumuşak geçiş
  Future<void> playMainMenuMusic() async {
    if (!_isMusicEnabled || _isAppInBackground) return;

    // Önce OGG formatını dene, yoksa MP3'e geç
    try {
      // Önce mevcut müziği yavaşça azalt
      await _fadeOutCurrentMusic();
      
      // Ana menü müziğini başlat (OGG)
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.setVolume(0.0); // Başlangıçta sessiz
      await _backgroundMusicPlayer.play(AssetSource('audio/ana-menü.ogg'));
      
      // Ana menü müziğini yavaşça artır
      await _fadeInNewMusic();
      
      _logger.info('🎵 Ana menü müziği çalınıyor (OGG)');
    } catch (e) {
      // OGG bulunamadıysa MP3'ü dene
      _logger.info('🎵 OGG bulunamadı, MP3 deneniyor: audio/ana-menü.mp3');
      
      try {
        // Önce mevcut müziği yavaşça azalt
        await _fadeOutCurrentMusic();
        
        // Ana menü müziğini başlat (MP3)
        await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
        await _backgroundMusicPlayer.setVolume(0.0); // Başlangıçta sessiz
        await _backgroundMusicPlayer.play(AssetSource('audio/ana-menü.mp3'));
        
        // Ana menü müziğini yavaşça artır
        await _fadeInNewMusic();
        
        _logger.info('🎵 Ana menü müziği çalınıyor (MP3)');
      } catch (e2) {
        _logger.error('Ana menü müziği bulunamadı (OGG ve MP3)', e2);
      }
    }
  }

  /// Arka plan müziğini devam ettir
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    
    try {
      await _backgroundMusicPlayer.resume();
      _logger.info('▶️ Arka plan müziği devam ettirildi');
    } catch (e) {
      _logger.error('Müzik devam ettirilirken hata oluştu', e);
    }
  }

  /// Ses efekti çal
  Future<void> playSoundEffect(String soundPath) async {
    if (!_isSoundEnabled || _isAppInBackground) return;

    try {
      await _soundEffectPlayer.setReleaseMode(ReleaseMode.release);
      await _soundEffectPlayer.setVolume(_soundVolume);
      await _soundEffectPlayer.play(AssetSource(soundPath));
      _logger.info('🔊 Ses efekti çalınıyor: $soundPath');
    } catch (e) {
      _logger.error('Ses efekti çalınırken hata oluştu', e);
    }
  }

  /// Müzik ses seviyesini ayarla
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _backgroundMusicPlayer.setVolume(_musicVolume);
    _logger.info('🔊 Müzik ses seviyesi ayarlandı: $_musicVolume');
  }

  /// Ses efekti ses seviyesini ayarla
  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume.clamp(0.0, 1.0);
    await _soundEffectPlayer.setVolume(_soundVolume);
    _logger.info('🔊 Ses efekti ses seviyesi ayarlandı: $_soundVolume');
  }

  /// Müziği aç/kapat
  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    
    if (_isMusicEnabled) {
      await resumeBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
    
    _logger.info('🎵 Müzik ${_isMusicEnabled ? 'açıldı' : 'kapatıldı'}');
  }

  /// Ses efektlerini aç/kapat
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    _logger.info('🔊 Ses efektleri ${_isSoundEnabled ? 'açıldı' : 'kapatıldı'}');
  }

  /// Uygulama arka plana alındığında çağrılır
  Future<void> onAppPaused() async {
    _isAppInBackground = true;
    
    try {
      await _backgroundMusicPlayer.pause();
      await _soundEffectPlayer.pause();
      _logger.info('⏸️ Uygulama arka plana alındı, müzik duraklatıldı');
    } catch (e) {
      _logger.error('Müzik duraklatılırken hata oluştu', e);
    }
  }

  /// Uygulama ön plana geldiğinde çağrılır
  Future<void> onAppResumed() async {
    _isAppInBackground = false;
    
    if (_isMusicEnabled) {
      try {
        await _backgroundMusicPlayer.resume();
        _logger.info('▶️ Uygulama ön plana geldi, müzik devam ediyor');
      } catch (e) {
        _logger.error('Müzik devam ettirilirken hata oluştu', e);
      }
    }
  }

  /// Servisi temizle
  Future<void> dispose() async {
    try {
      await _backgroundMusicPlayer.dispose();
      await _soundEffectPlayer.dispose();
      _logger.info('🧹 Audio servisi temizlendi');
    } catch (e) {
      _logger.error('Audio servisi temizlenirken hata oluştu', e);
    }
  }
} 