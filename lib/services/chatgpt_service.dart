import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger_service.dart';
import 'prompt_service.dart';
import '../models/game_category.dart';

/// ChatGPT API ile iletişimi sağlayan servis sınıfı
class ChatGPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final LoggerService _logger = LoggerService();
  final PromptService _promptService = PromptService();

  /// API anahtarını .env dosyasından alır
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// Model adını .env dosyasından alır
  String get _model => dotenv.env['OPENAI_MODEL'] ?? 'gpt-4.1-nano';

  /// ChatGPT API'ye metin isteği gönderir
  Future<String> generateContent(String prompt) async {
    _logger.debug('🤖 ChatGPT API isteği başlatılıyor');

    if (_apiKey.isEmpty) {
      _logger.error('❌ OPENAI_API_KEY bulunamadı');
      throw Exception(
        'OPENAI_API_KEY bulunamadı. .env dosyasını kontrol edin.',
      );
    }

    final url = Uri.parse(_baseUrl);
    _logger.apiRequest('POST', url.toString());

    final requestBody = {
      'model': _model,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'max_tokens': 1024,
      'top_p': 0.95,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    try {
      _logger.debug('📤 API isteği gönderiliyor');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      _logger.apiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _logger.debug('✅ API yanıtı başarıyla alındı');

        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null &&
            responseData['choices'][0]['message']['content'] != null) {
          final generatedText =
              responseData['choices'][0]['message']['content'];

          _logger.debug(
            '📝 Üretilen metin uzunluğu: ${generatedText.length} karakter',
          );
          return generatedText;
        } else {
          _logger.error('❌ API yanıtında metin bulunamadı', responseData);
          throw Exception('API yanıtında metin bulunamadı');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _logger.error('❌ API Hatası: ${response.statusCode}', errorData);
        throw Exception(
          'API Hatası: ${response.statusCode} - ${errorData['error']['message'] ?? 'Bilinmeyen hata'}',
        );
      }
    } catch (e, stackTrace) {
      _logger.error('💥 ChatGPT API isteği başarısız', e, stackTrace);

      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ağ hatası: $e');
    }
  }

  /// Sohbet geçmişi ile birlikte içerik üretir
  Future<String> generateContentWithHistory(
    String newPrompt,
    List<String> history,
  ) async {
    _logger.debug('🤖 ChatGPT API sohbet geçmişi ile istek başlatılıyor');

    if (_apiKey.isEmpty) {
      _logger.error('❌ OPENAI_API_KEY bulunamadı');
      throw Exception(
        'OPENAI_API_KEY bulunamadı. .env dosyasını kontrol edin.',
      );
    }

    final url = Uri.parse(_baseUrl);
    _logger.apiRequest('POST', url.toString());

    // Mesajları hazırla
    List<Map<String, String>> messages = [];

    // Sistem mesajı ekle - Sıkı hikaye yapısı ve karakter etkileşimi için gelişmiş talimat
    messages.add({
      'role': 'system',
      'content':
          '''Sen profesyonel bir interaktif hikaye anlatıcısısın. MUTLAKA hikaye yapısına uyacaksın.

ZORUNLU HİKAYE YAPISI - MUTLAKA TAKİP ET:

1. GİRİŞ AŞAMASI (Introduction):
   - Durumu ve atmosferi tanıt
   - Karakteri aksiyonun içine at
   - Dünyayı ve çevreyi betimle
   - Temel çatışmayı ima et
   - İsimlendirilmiş karakterleri tanıt

2. GELİŞME AŞAMASI (Development):
   - Olayları karmaşıklaştır
   - Yeni karakterler/tehlikeler tanıt
   - Gerilimi sürekli artır
   - Ana hedefe doğru ilerle
   - Karakter etkileşimlerini geliştir

3. DORUK AŞAMASI (Climax):
   - Ana çatışmayı başlat
   - En yoğun aksiyon ve drama
   - Kritik kararlar aldır
   - Karakterlerle yoğun etkileşim
   - Sonuca doğru hızlan

4. SONUÇ AŞAMASI (Conclusion):
   - Ana çatışmayı çöz
   - Hikayeyi tatmin edici şekilde sonlandır
   - Karakterlerin kaderini belirle
   - Sonlandırma ipuçları ver

KARAKTER VE ETKİLEŞİM KURALLARI - MUTLAKA UYGULA:
- Her hikayede isimlendirilmiş karakterler olsun
- Karakterlerle diyaloglar ve etkileşimler yaz
- Karakterlerin kişilikleri ve motivasyonları olsun
- Oyuncu karakterlerle konuşabilsin, tartışabilsin
- Gerçekçi karakter tepkileri ver

ÖZEL KATEGORI KURALLARI:
- SAVAŞ/TARİH kategorilerinde: Gerçek tarihten ilham al, tarihi atmosferi koru
- Tüm kategorilerde: İsimli karakterlerle zengin etkileşimler

AŞAMA KURALLARI:
- Her aşamada SADECE o aşamaya uygun içerik üret
- Giriş aşamasında sonuç verme
- Gelişme aşamasında hemen doruk noktasına çıkma
- Doruk aşamasında hikayeyi bitirme
- Sonuç aşamasında yeni maceralar başlatma

YAPMAN GEREKENLER:
- Kullanıcının seçiminin sonucunu detaylı ve sürükleyici şekilde anlat
- 3-5 paragraf yaz (200-400 kelime arası)
- Mevcut aşamaya uygun içerik üret
- Atmosferi güçlü ve detaylı şekilde betimle
- Karakterlerle zengin etkileşim kur
- Her cümleyi tamamla, yarıda bırakma
- Hikayeyi sürükleyici ve merak uyandırıcı şekilde devam ettir

YAPMAMANLAR:
- Aşama sıralamasını bozma
- Erken sonlandırma
- Aşama atlaması yapma
- Seçenek sunma
- "Ne yapmak istersin?" sorma
- İsimsiz, kişiliksiz karakterler yaratma

MUTLAKA hikaye aşamasına uygun içerik üret ve karakterlerle etkileşim kur!''',
    });

    // Geçmiş mesajları ekle
    for (String message in history) {
      if (message.startsWith('Player:')) {
        messages.add({'role': 'user', 'content': message.substring(7).trim()});
      } else if (message.startsWith('AI:')) {
        messages.add({
          'role': 'assistant',
          'content': message.substring(3).trim(),
        });
      }
    }

    // Yeni kullanıcı mesajını ekle
    messages.add({'role': 'user', 'content': newPrompt});

    final requestBody = {
      'model': _model,
      'messages': messages,
      'temperature': 0.8, // Daha yaratıcı hikaye devamı
      'max_tokens': 800, // Daha uzun ve detaylı hikaye için
      'top_p': 0.95,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    try {
      _logger.debug('📤 API isteği gönderiliyor (${messages.length} mesaj)');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      _logger.apiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _logger.debug('✅ API yanıtı başarıyla alındı');

        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null &&
            responseData['choices'][0]['message']['content'] != null) {
          final generatedText =
              responseData['choices'][0]['message']['content'];

          _logger.debug(
            '📝 Üretilen metin uzunluğu: ${generatedText.length} karakter',
          );
          return generatedText;
        } else {
          _logger.error('❌ API yanıtında metin bulunamadı', responseData);
          throw Exception('API yanıtında metin bulunamadı');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _logger.error('❌ API Hatası: ${response.statusCode}', errorData);
        throw Exception(
          'API Hatası: ${response.statusCode} - ${errorData['error']['message'] ?? 'Bilinmeyen hata'}',
        );
      }
    } catch (e, stackTrace) {
      _logger.error('💥 ChatGPT API isteği başarısız', e, stackTrace);

      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ağ hatası: $e');
    }
  }

  /// Hikaye özeti üretir
  Future<String> generateStorySummary(String prompt) async {
    _logger.debug('🤖 Hikaye özeti üretiliyor');

    if (_apiKey.isEmpty) {
      _logger.error('❌ OPENAI_API_KEY bulunamadı');
      throw Exception(
        'OPENAI_API_KEY bulunamadı. .env dosyasını kontrol edin.',
      );
    }

    final url = Uri.parse(_baseUrl);
    _logger.apiRequest('POST', url.toString());

    final requestBody = {
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': '''Sen profesyonel bir hikaye özetleyicisisin. Görevin:

TEMEL GÖREV: Tamamlanan hikayenin güzel ve duygusal bir özetini yaz.

YAPMAN GEREKENLER:
- Hikayenin ana olaylarını kronolojik sırayla özetle
- Karakterin yaptığı önemli kararları vurgula
- Duygusal ve atmosferik bir dil kullan
- Hikayenin sonucunu ve etkisini belirt
- Credits benzeri bir format kullan

YAPMAMANLAR:
- Seçenek sunma
- Soru sorma
- Tavsiye verme
- Gelecek hakkında spekülasyon yapma

Sadece özeti yaz, başka hiçbir şey ekleme.''',
        },
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.8, // Yaratıcı özet için
      'max_tokens': 400, // Kısa özet için
      'top_p': 0.95,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    try {
      _logger.debug('📤 Hikaye özeti API isteği gönderiliyor');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      _logger.apiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _logger.debug('✅ Hikaye özeti API yanıtı başarıyla alındı');

        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null &&
            responseData['choices'][0]['message']['content'] != null) {
          final summary = responseData['choices'][0]['message']['content'];

          _logger.debug('📝 Hikaye özeti uzunluğu: ${summary.length} karakter');
          return summary;
        } else {
          _logger.error(
            '❌ Hikaye özeti API yanıtında metin bulunamadı',
            responseData,
          );
          throw Exception('Hikaye özeti API yanıtında metin bulunamadı');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _logger.error(
          '❌ Hikaye özeti API Hatası: ${response.statusCode}',
          errorData,
        );
        throw Exception(
          'Hikaye özeti API Hatası: ${response.statusCode} - ${errorData['error']['message'] ?? 'Bilinmeyen hata'}',
        );
      }
    } catch (e, stackTrace) {
      _logger.error('💥 Hikaye özeti API isteği başarısız', e, stackTrace);

      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ağ hatası: $e');
    }
  }

  /// Yeni prompt sistemi ile hikaye başlatır
  Future<String> generateStoryIntroduction({
    required GameCategory category,
    required String characterName,
  }) async {
    _logger.debug('🤖 Hikaye başlangıcı üretiliyor');

    final prompt = _promptService.generateIntroductionPrompt(
      category: category,
      characterName: characterName,
    );

    return await _generateWithPrompt(prompt, temperature: 0.8, maxTokens: 700);
  }

  /// Yeni prompt sistemi ile hikaye devamı üretir
  Future<String> generateStoryContinuation({
    required GameCategory category,
    required String characterName,
    required List<String> history,
    required String userInput,
    required int turnCount,
  }) async {
    _logger.debug('🤖 Hikaye devamı üretiliyor (Tur: $turnCount)');

    final prompt = _promptService.generateContinuePrompt(
      category: category,
      characterName: characterName,
      history: history,
      userInput: userInput,
      turnCount: turnCount,
    );

    return await _generateWithPrompt(prompt, temperature: 0.8, maxTokens: 700);
  }

  /// Yeni prompt sistemi ile hikaye finali üretir
  Future<String> generateStoryFinale({
    required GameCategory category,
    required String characterName,
    required List<String> history,
    required String userInput,
    required int turnCount,
  }) async {
    _logger.debug('🤖 Hikaye finali üretiliyor');

    final prompt = _promptService.generateFinalPrompt(
      category: category,
      characterName: characterName,
      history: history,
      userInput: userInput,
      turnCount: turnCount,
    );

    return await _generateWithPrompt(prompt, temperature: 0.8, maxTokens: 900);
  }

  /// Yeni prompt sistemi ile hikaye özeti üretir
  Future<String> generateStoryCredits({
    required GameCategory category,
    required String characterName,
    required List<String> history,
  }) async {
    _logger.debug('🤖 Hikaye özeti (credits) üretiliyor');

    final prompt = _promptService.generateSummaryPrompt(
      category: category,
      characterName: characterName,
      history: history,
    );

    return await _generateWithPrompt(prompt, temperature: 0.8, maxTokens: 400);
  }

  /// Ortak API çağrısı metodu
  Future<String> _generateWithPrompt(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 200,
  }) async {
    if (_apiKey.isEmpty) {
      _logger.error('❌ OPENAI_API_KEY bulunamadı');
      throw Exception(
        'OPENAI_API_KEY bulunamadı. .env dosyasını kontrol edin.',
      );
    }

    final url = Uri.parse(_baseUrl);
    _logger.apiRequest('POST', url.toString());

    final requestBody = {
      'model': _model,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': 0.95,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    try {
      _logger.debug('📤 API isteği gönderiliyor');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      _logger.apiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _logger.debug('✅ API yanıtı başarıyla alındı');

        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null &&
            responseData['choices'][0]['message']['content'] != null) {
          final generatedText =
              responseData['choices'][0]['message']['content'];

          _logger.debug(
            '📝 Üretilen metin uzunluğu: ${generatedText.length} karakter',
          );
          return generatedText;
        } else {
          _logger.error('❌ API yanıtında metin bulunamadı', responseData);
          throw Exception('API yanıtında metin bulunamadı');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _logger.error('❌ API Hatası: ${response.statusCode}', errorData);
        throw Exception(
          'API Hatası: ${response.statusCode} - ${errorData['error']['message'] ?? 'Bilinmeyen hata'}',
        );
      }
    } catch (e, stackTrace) {
      _logger.error('💥 ChatGPT API isteği başarısız', e, stackTrace);

      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ağ hatası: $e');
    }
  }

  /// Epilog içeriği üretir
  Future<String> generateEpilogue(String prompt) async {
    _logger.debug('🤖 Epilog içeriği üretiliyor');

    if (_apiKey.isEmpty) {
      _logger.error('❌ OPENAI_API_KEY bulunamadı');
      throw Exception(
        'OPENAI_API_KEY bulunamadı. .env dosyasını kontrol edin.',
      );
    }

    final url = Uri.parse(_baseUrl);
    _logger.apiRequest('POST', url.toString());

    final requestBody = {
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': '''Sen profesyonel bir epilog yazarısısın. Görevin:

TEMEL GÖREV: Ana hikaye bittikten sonraki dönemi KISA şekilde anlat.

KISALIK KURALLARI - MUTLAKA UYGULA:
- SADECE 2-3 KISA cümle yaz (maksimum 120 kelime)
- Her cümleyi tamamla, yarıda bırakma
- Öz ve etkili ol

YAPMAN GEREKENLER:
- Ana hikaye sonrası yeni durumu KISA betimle
- Karakterin değişimini göster
- Yeni maceralara kapı aralayacak atmosfer kur
- Umut verici ton kullan

YAPMAMANLAR:
- Uzun paragraflar yazma
- Seçenek sunma
- Soru sorma
- Ana hikayeyi tekrar etme

MUTLAKA KISA epilog başlangıcı yaz.''',
        },
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.8, // Yaratıcı epilog için
      'max_tokens': 150, // Çok kısa epilog için
      'top_p': 0.95,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    try {
      _logger.debug('📤 Epilog API isteği gönderiliyor');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      _logger.apiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _logger.debug('✅ Epilog API yanıtı başarıyla alındı');

        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null &&
            responseData['choices'][0]['message']['content'] != null) {
          final epilogue = responseData['choices'][0]['message']['content'];

          _logger.debug('📝 Epilog uzunluğu: ${epilogue.length} karakter');
          return epilogue;
        } else {
          _logger.error(
            '❌ Epilog API yanıtında metin bulunamadı',
            responseData,
          );
          throw Exception('Epilog API yanıtında metin bulunamadı');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _logger.error('❌ Epilog API Hatası: ${response.statusCode}', errorData);
        throw Exception(
          'Epilog API Hatası: ${response.statusCode} - ${errorData['error']['message'] ?? 'Bilinmeyen hata'}',
        );
      }
    } catch (e, stackTrace) {
      _logger.error('💥 Epilog API isteği başarısız', e, stackTrace);

      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ağ hatası: $e');
    }
  }
}
