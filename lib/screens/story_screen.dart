import 'dart:async';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sezyon/models/game_category.dart';
import 'package:sezyon/models/message.dart';
import 'package:sezyon/services/gemini_service.dart';
import 'package:sezyon/services/language_service.dart';
import 'package:sezyon/services/logger_service.dart';

class StoryScreen extends StatefulWidget {
  final GameCategory category;

  const StoryScreen({super.key, required this.category});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final List<Message> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _geminiService = GeminiService();
  late final LanguageService _languageService;
  late final LoggerService _logger;

  bool _isLoading = true;
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    _languageService = LanguageService();
    _logger = LoggerService();
    _startGame();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    setState(() => _isLoading = true);
    _logger.gameEvent('Oyun başlatılıyor', {'category': widget.category.name});

    try {
      final initialPrompt = widget.category.getInitialPrompt();
      final initialStory = await _geminiService.generateContent(initialPrompt);
      
      final firstMessage = Message(text: initialStory, isUser: false);
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
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final userMessage = Message(text: text, isUser: true, isAnimated: true);
    setState(() {
      _messages.insert(0, userMessage);
      _isAiTyping = true;
    });

    _logger.gameEvent('Kullanıcı mesaj gönderdi', {'message': text});
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _textController.clear();

    try {
      final history = _messages
          .where((m) => m.isAnimated)
          .map((m) => "${m.isUser ? 'Player' : 'AI'}: ${m.text}")
          .toList()
          .reversed
          .toList();

      final continuePrompt = widget.category.getContinuePrompt(text, history);
      final response = await _geminiService.generateContent(continuePrompt);

      final aiMessage = Message(text: response, isUser: false);
      if (mounted) {
        setState(() {
          _messages.insert(0, aiMessage);
          _isAiTyping = false;
        });
      }
      _logger.info('Yapay zeka yanıtı alındı');
    } catch (e, stackTrace) {
      _logger.error('Yapay zeka yanıtı alınamadı', e, stackTrace);
      if (mounted) {
        setState(() => _isAiTyping = false);
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
            icon: const Icon(Icons.refresh),
            onPressed: _messages.isNotEmpty && !_isLoading ? _showRestartDialog : null,
            tooltip: _languageService.restart,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Ana içerik
          Column(
            children: [
              Expanded(
                child: _isLoading && _messages.isEmpty
                    ? const SizedBox.shrink() // Yüklenirken listeyi gösterme
                    : _buildMessageList(),
              ),
              if (_isAiTyping) _buildTypingIndicator(),
              _buildMessageInput(),
            ],
          ),
          // Yükleme göstergesi ve karartma efekti için katman
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: Container(
              color: Colors.black,
              child: Center(
                child: _buildLoadingIndicator(),
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
            _languageService.storyLoading, // Değişkeni kullandık
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
      padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 60, 10, 10),
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isUser || message.isAnimated
            ? Text(
                message.text,
                style: GoogleFonts.sourceSans3(color: Colors.white, fontSize: 16, height: 1.4),
              )
            : AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    message.text,
                    textStyle: GoogleFonts.sourceSans3(color: Colors.white, fontSize: 16, height: 1.4),
                    speed: const Duration(milliseconds: 30),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                onFinished: () {
                  if (mounted) {
                    setState(() => message.isAnimated = true);
                  }
                },
              ),
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
          const SizedBox(width: 8),
          Text(
            _languageService.aiThinking,
            style: GoogleFonts.sourceSans3(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _languageService.inputHint,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  style: GoogleFonts.sourceSans3(color: Colors.white, fontSize: 16),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 