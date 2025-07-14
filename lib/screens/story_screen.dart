import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/game_category.dart';
import '../models/message.dart';
import '../services/gemini_service.dart';
import '../services/language_service.dart';
import '../services/logger_service.dart';

/// Hikaye oynanış ekranı
class StoryScreen extends StatefulWidget {
  final GameCategory category;

  const StoryScreen({super.key, required this.category});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final LanguageService _languageService = LanguageService();
  final LoggerService _logger = LoggerService();
  
  bool _isLoading = false;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Oyunu başlatır ve ilk hikayeyi alır
  Future<void> _startGame() async {
    _logger.gameEvent('Oyun başlatılıyor', {
      'category': widget.category.key,
      'language': _languageService.currentLanguageCode,
    });

    setState(() {
      _isLoading = true;
    });

    try {
      final initialPrompt = widget.category.getInitialPrompt();
      final response = await _geminiService.generateContent(initialPrompt);
      
      setState(() {
        _messages.add(Message.ai(response));
        _gameStarted = true;
        _isLoading = false;
      });
      
      _scrollToBottom();
      _logger.gameEvent('Oyun başarıyla başlatıldı');
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      
      _logger.error('Oyun başlatılırken hata', e, stackTrace);
      _showErrorDialog(
        _languageService.getLocalizedText(
          'Oyun başlatılırken hata oluştu: $e',
          'Error starting game: $e',
        ),
      );
    }
  }

  /// Kullanıcının mesajını gönderir
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _logger.gameEvent('Kullanıcı mesajı gönderiliyor', {
      'messageLength': text.length,
      'language': _languageService.currentLanguageCode,
    });

    // Kullanıcı mesajını ekle
    setState(() {
      _messages.add(Message.user(text));
      _isLoading = true;
    });
    
    _textController.clear();
    _scrollToBottom();

    try {
      // Sohbet geçmişini hazırla
      final labelPlayer = _languageService.getLocalizedText("Oyuncu", "Player");
      final labelNarrator = _languageService.getLocalizedText("Anlatıcı", "Narrator");
      
      List<String> conversationHistory = _messages
          .map((msg) => '${msg.isUser ? labelPlayer : labelNarrator}: ${msg.content}')
          .toList();

      // Devam prompt'u oluştur ve gönder
      final continuePrompt = widget.category.getContinuePrompt(text, conversationHistory);
      final response = await _geminiService.generateContent(continuePrompt);
      
      setState(() {
        _messages.add(Message.ai(response));
        _isLoading = false;
      });
      
      _scrollToBottom();
      _logger.gameEvent('AI yanıtı alındı');
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      
      _logger.error('Mesaj gönderilirken hata', e, stackTrace);
      _showErrorDialog(
        _languageService.getLocalizedText(
          'Mesaj gönderilirken hata oluştu: $e',
          'Error sending message: $e',
        ),
      );
    }
  }

  /// En alta kaydırır
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Hata dialog'u gösterir
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_languageService.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
        title: Text(_languageService.getAdventureTitle(widget.category.key)),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _gameStarted ? () => _showRestartDialog() : null,
            tooltip: _languageService.restart,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            if (_gameStarted) _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /// Mesaj listesini oluşturur
  Widget _buildMessageList() {
    if (!_gameStarted && _isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              _languageService.storyLoading,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _messages.length) {
          return _buildTypingIndicator();
        }
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// AI yazıyor göstergesi
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              _languageService.aiThinking,
              style: GoogleFonts.lato(
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mesaj balonunu oluşturur
  Widget _buildMessageBubble(Message message) {
    final bool isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser
        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
        : Theme.of(context).colorScheme.surface.withOpacity(0.8);
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: Text(
          message.content,
          style: GoogleFonts.lato(
            fontSize: 16,
            height: 1.5,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
      ),
    );
  }

  /// Giriş alanını oluşturur
  Widget _buildInputArea() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          color: Colors.black.withOpacity(0.2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: _languageService.inputHint,
                    prefixIcon: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isLoading,
                  style: GoogleFonts.lato(),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                onPressed: _isLoading ? null : _sendMessage,
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 4,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Yeniden başlatma dialog'u gösterir
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

  /// Oyunu yeniden başlatır
  void _restartGame() {
    setState(() {
      _messages.clear();
      _gameStarted = false;
    });
    _startGame();
  }
} 