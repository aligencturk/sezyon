import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger_service.dart';

/// Gemini AI API ile iletişimi sağlayan servis sınıfı
class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models';
  final LoggerService _logger = LoggerService();
  
  /// API anahtarını .env dosyasından alır
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  /// Model adını .env dosyasından alır
  String get _model => dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.0-flash';

  /// Gemini API'ye metin isteği gönderir
  Future<String> generateContent(String prompt) async {
    _logger.debug('🤖 Gemini API isteği başlatılıyor');
    
    if (_apiKey.isEmpty) {
      _logger.error('❌ GEMINI_API_KEY bulunamadı');
      throw Exception('GEMINI_API_KEY bulunamadı. .env dosyasını kontrol edin.');
    }

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');
    _logger.apiRequest('POST', url.toString());
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': prompt
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      }
    };

    try {
      _logger.debug('📤 API isteği gönderiliyor');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      _logger.apiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _logger.debug('✅ API yanıtı başarıyla alındı');
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final generatedText = responseData['candidates'][0]['content']['parts'][0]['text'] ?? 
                 'Beklenmeyen API yanıtı';
          
          _logger.debug('📝 Üretilen metin uzunluğu: ${generatedText.length} karakter');
          return generatedText;
        } else {
          _logger.error('❌ API yanıtında metin bulunamadı', responseData);
          throw Exception('API yanıtında metin bulunamadı');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _logger.error('❌ API Hatası: ${response.statusCode}', errorData);
        throw Exception('API Hatası: ${response.statusCode} - ${errorData['error']['message'] ?? 'Bilinmeyen hata'}');
      }
    } catch (e, stackTrace) {
      _logger.error('💥 Gemini API isteği başarısız', e, stackTrace);
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ağ hatası: $e');
    }
  }

  /// Sohbet geçmişi ile birlikte içerik üretir
  Future<String> generateContentWithHistory(String newPrompt, List<String> history) async {
    // Geçmişi prompt'a dahil et
    String fullPrompt = '';
    if (history.isNotEmpty) {
      fullPrompt = 'Önceki konuşma:\n${history.join('\n\n')}\n\nYeni istek: $newPrompt';
    } else {
      fullPrompt = newPrompt;
    }
    
    return await generateContent(fullPrompt);
  }
} 