import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text(_languageService.getAdventureTitle(widget.category.key)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _gameStarted ? () => _showRestartDialog() : null,
            tooltip: _languageService.restart,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mesaj listesi
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade50,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: _buildMessageList(),
            ),
          ),
          
          // Giriş alanı
          if (_gameStarted) _buildInputArea(),
        ],
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
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _messages.length) {
          // Yükleniyor göstergesi
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
                         child: Row(
               children: [
                 const SizedBox(
                   width: 20,
                   height: 20,
                   child: CircularProgressIndicator(strokeWidth: 2),
                 ),
                 const SizedBox(width: 12),
                 Text(_languageService.aiThinking),
               ],
             ),
          );
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// Mesaj balonunu oluşturur
  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade600,
              child: const Icon(Icons.auto_stories, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue.shade600 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green.shade600,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  /// Giriş alanını oluşturur
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _languageService.inputHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: _isLoading 
                ? Colors.grey 
                : Theme.of(context).primaryColor,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
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