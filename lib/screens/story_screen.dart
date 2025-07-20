import 'dart:async';
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
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _chatgptService = ChatGPTService();
  late final LanguageService _languageService;
  late final LoggerService _logger;
  final AudioService _audioService = AudioService();

  bool _isLoading = true;
  bool _isWaitingForApiResponse = false;
  bool _isStoryEnded = false;

  String? _storySummary;
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
    _textController.dispose();
    _focusNode.dispose();
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

      final firstMessage = Message(
        text: initialStory,
        isUser: false,
        storyPhase: StoryPhase.introduction,
        isStoryEnd: false,
        isAnimated: false,
      );

      if (mounted) {
        setState(() {
          _messages.add(firstMessage);
          _isLoading = false;
        });
      }
      _logger.gameEvent('İlk hikaye alındı');
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

  Future<void> _sendMessage() async {
    final userInput = _textController.text.trim();
    if (userInput.isEmpty || _isWaitingForApiResponse) return;

    _logger.gameEvent('Kullanıcı mesaj gönderdi', {'message': userInput});

    // Kullanıcı mesajını ekle
    final userMessage = Message(
      text: userInput,
      isUser: true,
      isAnimated: true,
    );

    setState(() {
      _messages.insert(0, userMessage);
      _isWaitingForApiResponse = true;
    });

    // Text field'ı temizle
    _textController.clear();

    // Scroll'u en üste taşı
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      // Mesaj geçmişini hazırla
      final history = _messages
          .where((m) => m.isAnimated)
          .map((m) => "${m.isUser ? 'Player' : 'AI'}: ${m.text}")
          .toList()
          .reversed
          .toList();

      // Mevcut hikaye aşamasını belirle
      final currentPhase = widget.category.determineStoryPhase(history);

      // API çağrısı yap
      final response = await _chatgptService.generateContentWithHistory(
        userInput,
        history,
      );

      // Hikayenin sonlanıp sonlanmadığını kontrol et
      final shouldEnd = widget.category.shouldEndStory(history, response);

      if (shouldEnd) {
        _isStoryEnded = true;
        // Hikaye özeti üret
        try {
          final summaryPrompt = widget.category.getStorySummaryPrompt(
            history,
            _languageService.isTurkish,
          );
          _storySummary = await _chatgptService.generateStorySummary(
            summaryPrompt,
          );
        } catch (e) {
          _storySummary = _languageService.getLocalizedText(
            'Hikayeniz tamamlandı! Maceranız boyunca verdiğiniz kararlar sizi bu noktaya getirdi.',
            'Your story is complete! The decisions you made throughout your adventure brought you to this point.',
          );
        }
      }

      final aiMessage = Message(
        text: response,
        isUser: false,
        storyPhase: currentPhase,
        isStoryEnd: shouldEnd,
        isAnimated: false,
      );

      if (mounted) {
        setState(() {
          _isWaitingForApiResponse = false;
          _messages.insert(0, aiMessage);
        });
      }

      _logger.info('Yapay zeka yanıtı alındı');
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
      _isStoryEnded = false;
      _storySummary = null;
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

  void _showStorySummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        title: Row(
          children: [
            Icon(
              Icons.auto_stories,
              color: Colors.amber.withValues(alpha: 0.8),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              _languageService.getLocalizedText(
                'Hikaye Özeti',
                'Story Summary',
              ),
              style: GoogleFonts.merriweather(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              _storySummary ??
                  _languageService.getLocalizedText(
                    'Hikaye özeti yükleniyor...',
                    'Story summary loading...',
                  ),
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _languageService.ok,
              style: const TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _startEpilogue() async {
    setState(() {
      _isLoading = true;
      _isStoryEnded = false;
    });

    try {
      final history = _messages
          .where((m) => m.isAnimated)
          .map((m) => "${m.isUser ? 'Player' : 'AI'}: ${m.text}")
          .toList()
          .reversed
          .toList();

      final epiloguePrompt = widget.category.getEpiloguePrompt(
        history,
        _languageService.isTurkish,
      );

      final epilogueContent = await _chatgptService.generateEpilogue(
        epiloguePrompt,
      );

      final epilogueMessage = Message(
        text: epilogueContent,
        isUser: false,
        storyPhase: StoryPhase.epilogue,
        isStoryEnd: false,
        isEpilogue: true,
        isAnimated: false,
      );

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.add(epilogueMessage);
          _isLoading = false;
        });
      }

      _logger.gameEvent('Epilog başlatıldı');
    } catch (e, stackTrace) {
      _logger.error('Epilog başlatılamadı', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isStoryEnded = true;
        });
        _showErrorDialog(e.toString());
      }
    }
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
        backgroundColor: Colors.black.withValues(alpha: 0.3),
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
          Column(
            children: [
              Expanded(
                child: _isLoading && _messages.isEmpty
                    ? const SizedBox.shrink()
                    : _buildMessageList(),
              ),
              if (_isWaitingForApiResponse) _buildTypingIndicator(),
              if (_isStoryEnded) _buildStoryEndButtons() else _buildInputArea(),
            ],
          ),
          // Yükleme göstergesi
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
              color: Colors.white.withValues(alpha: 0.8),
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
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.computer,
                  color: Colors.purple.withValues(alpha: 0.8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      _languageService.storyContinuing,
                      textStyle: GoogleFonts.sourceSans3(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      speed: const Duration(milliseconds: 80),
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                  pause: const Duration(milliseconds: 1000),
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
        : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6);

    // AI mesajları için animasyonlu metin
    if (!isUserMessage && !message.isAnimated) {
      message.isAnimated = true;
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
                if (mounted) {
                  setState(() {
                    // Animasyon tamamlandığında UI'ı güncelle
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

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.0,
        8.0,
        16.0,
        MediaQuery.of(context).padding.bottom + 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              enabled: !_isWaitingForApiResponse,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: GoogleFonts.sourceSans3(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: _languageService.getLocalizedText(
                  'Ne yapmak istiyorsun?',
                  'What do you want to do?',
                ),
                hintStyle: GoogleFonts.sourceSans3(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: _isWaitingForApiResponse ? null : _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              tooltip: _languageService.getLocalizedText('Gönder', 'Send'),
            ),
          ),
        ],
      ),
    );
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
                      _languageService.getLocalizedText(
                        'Hikayenizin özetini görmek ister misiniz?',
                        'Would you like to see your story summary?',
                      ),
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
          // Butonlar
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showStorySummary,
                  icon: const Icon(Icons.auto_stories),
                  label: Text(
                    _languageService.getLocalizedText('Özet', 'Summary'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.withValues(alpha: 0.2),
                    foregroundColor: Colors.amber,
                    side: BorderSide(
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startEpilogue,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    _languageService.getLocalizedText('Epilog', 'Epilogue'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    _languageService.getLocalizedText('Yeniden', 'Restart'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
