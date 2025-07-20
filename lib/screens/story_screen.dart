import 'dart:async';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sezyon/models/game_category.dart';
import 'package:sezyon/models/message.dart';
import 'package:sezyon/services/chatgpt_service.dart';
import 'package:sezyon/services/language_service.dart';
import 'package:sezyon/services/logger_service.dart';
import 'package:sezyon/services/audio_service.dart';

class StoryScreen extends StatefulWidget {
  final GameCategory category;

  const StoryScreen({super.key, required this.category});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final List<Message> _messages = [];
  final _scrollController = ScrollController();
  final _chatgptService = ChatGPTService();
  late final LanguageService _languageService;
  late final LoggerService _logger;
  final AudioService _audioService = AudioService();

  bool _isLoading = true;
  bool _isWaitingForApiResponse = false;
  bool _isStoryEnded = false;
  double _musicVolume = 0.5;
  double _soundVolume = 0.7;
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _languageService = LanguageService();
    _logger = LoggerService();
    _loadAudioSettings();
    _startGame();
  }

  void _loadAudioSettings() {
    _musicVolume = _audioService.musicVolume;
    _soundVolume = _audioService.soundVolume;
    _isMusicEnabled = _audioService.isMusicEnabled;
    _isSoundEnabled = _audioService.isSoundEnabled;
  }

  @override
  void dispose() {
    _scrollController.dispose();

    // Audio servisini sıfırla (hot restart için)
    _audioService.reset();

    super.dispose();
  }

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
    });
    _logger.gameEvent('Oyun başlatılıyor', {'category': widget.category.name});

    // Kategori bazlı müziğe geç
    await _audioService.playCategoryMusic(widget.category.key);

    try {
      final initialPrompt = widget.category.getInitialPrompt();
      final initialStory = await _chatgptService.generateContent(initialPrompt);

      // İlk hikayeden sonra seçenekler üret
      final choices = await _chatgptService.generateChoices(initialStory, []);

      final firstMessage = Message(
        text: initialStory,
        isUser: false,
        hasChoices: true,
        choices: choices,
        storyPhase: StoryPhase.introduction,
        isStoryEnd: false,
        isAnimated: false, // Başlangıçta animasyon yapılmamış
      );

      print('🎮 İlk mesaj oluşturuldu:');
      print('   - text: ${initialStory.substring(0, 50)}...');
      print('   - hasChoices: ${firstMessage.hasChoices}');
      print('   - choices: ${choices.length} seçenek');

      if (mounted) {
        setState(() {
          _messages.add(firstMessage);
          _isLoading = false;
        });
      }
      _logger.gameEvent('İlk hikaye ve seçenekler alındı');
    } catch (e, stackTrace) {
      _logger.error('Oyun başlatılamadı', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  void _selectChoice(Choice choice) async {
    print('🎯 _selectChoice çağrıldı: ${choice.text}');
    print('🎯 Seçenek ID: ${choice.id}');
    _logger.gameEvent('Kullanıcı seçenek seçti', {'choice': choice.text});

    // Eğer zaten API yanıtı bekleniyorsa, yeni seçim yapılmasını engelle
    if (_isWaitingForApiResponse) {
      print('🎯 API yanıtı bekleniyor, yeni seçim engellendi');
      return;
    }

    // Seçilen seçeneği kullanıcı mesajı olarak ekle
    final userMessage = Message(
      text: choice.text,
      isUser: true,
      isAnimated: true,
    );
    print('🎯 Kullanıcı mesajı oluşturuldu');

    setState(() {
      _messages.insert(0, userMessage);
      _isWaitingForApiResponse = true;
    });
    print('🎯 State güncellendi - mesaj sayısı: ${_messages.length}');

    // Scroll'u en üste taşı
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      print('🎯 API çağrısı başlatılıyor...');

      // Sadece animasyonu tamamlanmış mesajları history'ye ekle
      final history = _messages
          .where((m) => m.isAnimated)
          .map((m) => "${m.isUser ? 'Player' : 'AI'}: ${m.text}")
          .toList()
          .reversed
          .toList();

      print('🎯 History hazırlandı - ${history.length} mesaj');
      final continuePrompt = widget.category.getContinuePrompt(
        choice.text,
        history,
      );
      print('🎯 Prompt hazırlandı');

      print('🎯 ChatGPT API çağrılıyor...');
      final response = await _chatgptService.generateContentWithHistory(
        choice.text,
        history,
      );
      print('🎯 ChatGPT yanıtı alındı: ${response.substring(0, 50)}...');

      // Hikayenin sonlanıp sonlanmadığını kontrol et
      final shouldEnd = widget.category.shouldEndStory(history, response);
      final currentPhase = widget.category.determineStoryPhase(history);

      print('🎯 Hikaye aşaması: $currentPhase');
      print('🎯 Hikaye sonlanmalı mı: $shouldEnd');

      List<Choice> choices = [];
      bool hasChoices = true;

      if (shouldEnd) {
        // Hikaye sonlandı - seçenek sunma
        hasChoices = false;
        _isStoryEnded = true;
        print('🎯 Hikaye sonlandı - seçenek üretilmiyor');
      } else {
        // Hikaye devam ediyor - seçenekler üret
        print('🎯 Seçenekler üretiliyor...');
        choices = await _chatgptService.generateChoices(response, history);
        print('🎯 ${choices.length} seçenek üretildi');
      }

      final aiMessage = Message(
        text: response,
        isUser: false,
        hasChoices: hasChoices,
        choices: hasChoices ? choices : null,
        storyPhase: currentPhase,
        isStoryEnd: shouldEnd,
        isAnimated: false, // Başlangıçta animasyon yapılmamış
      );
      print('🎯 AI mesajı oluşturuldu');

      if (mounted) {
        setState(() {
          _isWaitingForApiResponse = false;
          _messages.insert(0, aiMessage);
        });
        print('🎯 AI mesajı eklendi, state güncellendi');
      }

      _logger.info('Yapay zeka yanıtı ve seçenekler alındı');
    } catch (e, stackTrace) {
      _logger.error('Yapay zeka yanıtı alınamadı', e, stackTrace);
      if (mounted) {
        setState(() {
          _isWaitingForApiResponse = false;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  void _restartGame() {
    _logger.gameEvent('Oyun yeniden başlatılıyor');
    setState(() {
      _messages.clear();
      _isLoading = true;
    });
    _startGame();
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

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_languageService.restartGame),
        content: Text(_languageService.restartConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_languageService.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: Text(_languageService.restart),
          ),
        ],
      ),
    );
  }

  void _showAudioSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.blue),
              const SizedBox(width: 8),
              Text(_languageService.audioSettings),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Müzik ayarları
                Row(
                  children: [
                    Icon(
                      _isMusicEnabled ? Icons.music_note : Icons.music_off,
                      color: _isMusicEnabled ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _languageService.musicVolume,
                        style: GoogleFonts.sourceSans3(fontSize: 16),
                      ),
                    ),
                    Switch(
                      value: _isMusicEnabled,
                      onChanged: (value) {
                        setDialogState(() {
                          _isMusicEnabled = value;
                        });
                        _audioService.toggleMusic();
                      },
                    ),
                  ],
                ),
                if (_isMusicEnabled) ...[
                  Slider(
                    value: _musicVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_musicVolume * 100).round()}%',
                    onChanged: (value) {
                      setDialogState(() {
                        _musicVolume = value;
                      });
                      _audioService.setMusicVolume(value);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                // Ses efektleri ayarları
                Row(
                  children: [
                    Icon(
                      _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _isSoundEnabled ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _languageService.soundEffectsVolume,
                        style: GoogleFonts.sourceSans3(fontSize: 16),
                      ),
                    ),
                    Switch(
                      value: _isSoundEnabled,
                      onChanged: (value) {
                        setDialogState(() {
                          _isSoundEnabled = value;
                        });
                        _audioService.toggleSound();
                      },
                    ),
                  ],
                ),
                if (_isSoundEnabled) ...[
                  Slider(
                    value: _soundVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_soundVolume * 100).round()}%',
                    onChanged: (value) {
                      setDialogState(() {
                        _soundVolume = value;
                      });
                      _audioService.setSoundVolume(value);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_languageService.ok),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _languageService.getAdventureTitle(widget.category.key),
          style: GoogleFonts.merriweather(fontSize: 20),
        ),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _showAudioSettingsDialog,
            tooltip: _languageService.audioSettings,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _messages.isNotEmpty && !_isLoading
                ? _showRestartDialog
                : null,
            tooltip: _languageService.restart,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Ana içerik
          Column(
            children: [
              Expanded(
                child: _isLoading && _messages.isEmpty
                    ? const SizedBox.shrink()
                    : _buildMessageList(),
              ),
              if (_isWaitingForApiResponse) _buildTypingIndicator(),
              _buildChoiceButtons(),
            ],
          ),
          // Yükleme göstergesi ve karartma efekti için katman
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: IgnorePointer(
              ignoring: !_isLoading,
              child: Container(
                color: Colors.black,
                child: Center(child: _buildLoadingIndicator()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            _languageService.storyLoading,
            textStyle: GoogleFonts.sourceSans3(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
            ),
            speed: const Duration(milliseconds: 100),
          ),
        ],
        isRepeatingAnimation: true,
        repeatForever: true,
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.fromLTRB(
        10,
        MediaQuery.of(context).padding.top + 60,
        10,
        10,
      ),
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bilgisayar ikonu
                Icon(
                  Icons.computer,
                  color: Colors.purple.withOpacity(0.8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                // Typewriter animasyonu
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      _languageService.storyContinuing,
                      textStyle: GoogleFonts.sourceSans3(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      speed: const Duration(
                        milliseconds: 80,
                      ), // Typewriter hızı
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                  pause: const Duration(
                    milliseconds: 1000,
                  ), // Her tekrar arasında bekleme
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUserMessage = message.isUser;
    final alignment = isUserMessage
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final color = isUserMessage
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary.withOpacity(0.6);

    // AI mesajları için animasyonlu metin
    if (!isUserMessage && !message.isAnimated) {
      message.isAnimated = true;
      print(
        '🎬 AI mesajı animasyonu başlatılıyor: ${message.text.substring(0, 30)}...',
      );
      return Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Align(
          alignment: alignment,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 18.0,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  message.text,
                  textStyle: GoogleFonts.sourceSans3(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  speed: const Duration(milliseconds: 30),
                ),
              ],
              isRepeatingAnimation: false,
              totalRepeatCount: 1,
              onFinished: () {
                print('🎬 AI mesajı animasyonu tamamlandı');
                if (mounted) {
                  setState(() {
                    // Animasyon tamamlandığında UI'ı güncelle
                    print('🎬 State güncellendi - seçenekler gösterilecek');
                  });
                }
              },
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: GoogleFonts.sourceSans3(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButtons() {
    // Son AI mesajını bul (en üstteki AI mesajı)
    final lastAiMessage = _messages.where((m) => !m.isUser).firstOrNull;

    print('🎯 _buildChoiceButtons çağrıldı');
    print('🎯 Toplam mesaj sayısı: ${_messages.length}');
    print('🎯 AI mesajı bulundu mu: ${lastAiMessage != null}');
    print('🎯 API yanıtı bekleniyor mu: $_isWaitingForApiResponse');
    print('🎯 Hikaye sonlandı mı: $_isStoryEnded');

    if (lastAiMessage == null || _isWaitingForApiResponse) {
      print(
        '🎯 Seçenekler gösterilmiyor - AI mesajı yok veya API yanıtı bekleniyor',
      );
      return const SizedBox.shrink();
    }

    // AI mesajının animasyonu tamamlanmış mı kontrol et
    if (!lastAiMessage.isAnimated) {
      print('🎯 AI mesajının animasyonu henüz tamamlanmamış');
      return const SizedBox.shrink();
    }

    // Hikaye sonlandıysa özel UI göster
    if (lastAiMessage.isStoryEnd == true) {
      return _buildStoryEndButtons();
    }

    // Normal seçenekler
    if (lastAiMessage.hasChoices && lastAiMessage.choices != null) {
      print(
        '🎯 Seçenekler gösteriliyor - ${lastAiMessage.choices!.length} seçenek',
      );

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: lastAiMessage.choices!.asMap().entries.map((entry) {
            final index = entry.key;
            final choice = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 150)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: index == lastAiMessage.choices!.length - 1
                            ? 0
                            : 6,
                      ),
                      child: _buildChoiceButton(choice),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStoryEndButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        border: Border(
          top: BorderSide(color: Colors.amber.withValues(alpha: 0.3), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hikaye sonu ikonu ve mesajı
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 48,
                      color: Colors.amber.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _languageService.storyCompleted,
                      style: GoogleFonts.merriweather(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _languageService.storyEndMessage,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Aksiyon butonları
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(_languageService.mainMenu),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isStoryEnded = false;
                          });
                          _restartGame();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(_languageService.newStory),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(Choice choice) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('SEÇENEK TIKLANDI: ${choice.text}');
          _selectChoice(choice);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            choice.text,
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
