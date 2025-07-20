import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger_service.dart';
import '../models/message.dart';

/// ChatGPT API ile iletişimi sağlayan servis sınıfı
class ChatGPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final LoggerService _logger = LoggerService();

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

    // Sistem mesajı ekle - Hedef tabanlı hikaye anlatımı için gelişmiş talimat
    messages.add({
      'role': 'system',
      'content':
          '''Sen profesyonel bir interaktif hikaye anlatıcısısın. Görevin:

TEMEL GÖREV: Kullanıcının seçtiği eylemi gerçekleştirdiğini varsayarak hikayenin sonucunu anlat.

HİKAYE YAPISINI TAKİP ET:
- GİRİŞ: Durumu tanıt, atmosfer kur, karakteri aksiyonun içine at
- GELİŞME: Olayları karmaşıklaştır, gerilimi artır, ana hedefe doğru ilerle
- DORUK: Ana çatışmayı başlat, kritik kararlar aldır, yoğun aksiyon
- SONUÇ: Hikayeyi tatmin edici şekilde sonlandır

YAPMAN GEREKENLER:
- Kullanıcının seçiminin sonucunu detaylı anlat
- Hikayeyi 2-3 cümle ile devam ettir
- Atmosferi ve duyguları güçlü şekilde betimle
- Hikayenin akışını sürdür
- Hikaye sonuna yaklaştığında sonlandırma ipuçları ver

SONLANDIRMA İPUÇLARI (hikaye sonuna yaklaştığında kullan):
- "...ve böylece macera sona erdi"
- "...son kez arkana bakarak yürüdün"
- "...hikaye burada son buldu"
- "...artık her şey bitmişti"

ÖZEL DURUM - KARAR BIRAKMA (bazen yap):
Eğer hikayede kritik bir an gelirse, kullanıcıya küçük bir karar bırakabilirsin:
- "Kapının arkasından sesler geliyor..." (karar: açmak mı beklemek mi)
- "İki yol ayrımındasın..." (karar: hangi yolu seçmek)
- "Bir şey fark ettin ama emin değilsin..." (karar: araştırmak mı görmezden gelmek mi)

YAPMAMANLAR:
- Büyük seçenekler listesi verme
- "Ne yapmak istersin?" gibi genel sorular sorma
- Sürekli karar bırakma (sadece bazen)
- Tavsiye verme
- Hikayeyi gereksiz uzatma

Hikayeyi doğal akışında ilerlet ve uygun zamanda sonlandır.''',
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
      'max_tokens': 250, // Daha kısa ve odaklı yanıtlar
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

  /// Hikaye seçenekleri üretir
  Future<List<Choice>> generateChoices(
    String storyContext,
    List<String> history,
  ) async {
    _logger.debug('🤖 Hikaye seçenekleri üretiliyor');

    if (_apiKey.isEmpty) {
      _logger.error('❌ OPENAI_API_KEY bulunamadı');
      throw Exception(
        'OPENAI_API_KEY bulunamadı. .env dosyasını kontrol edin.',
      );
    }

    final url = Uri.parse(_baseUrl);
    _logger.apiRequest('POST', url.toString());

    // Gelişmiş seçenek üretme prompt'u
    final choicePrompt =
        '''
Mevcut hikaye durumu: $storyContext

Bu hikaye için 4 farklı, kaliteli seçenek üret. Her seçenek:

ZORUNLU KURALLAR:
- Hikayenin mevcut durumu ile DOĞRUDAN bağlantılı olmalı
- Her seçenek hikayeyi FARKLI bir yöne götürmeli
- Mantıklı ve gerçekçi olmalı
- 1. şahıs olarak yazılmalı ("Kapıyı açıyorum", "Silahımı çekerim")
- Kısa ve net olmalı (maksimum 1-2 cümle)

ÖNEMLİ: Eğer hikaye bir karar noktasında bitiyorsa (örn: "iki yol var", "kapının arkasından ses geliyor"), seçenekleri o karara uygun üret.

SEÇENEK TİPLERİ:
Normal durumlar için:
1. AKSIYON seçeneği (saldırgan/cesur hareket)
2. DİPLOMATİK seçeneği (konuşma/ikna etme)
3. GÖZLEM seçeneği (araştırma/bekleme)
4. KAÇIŞ/SAVUNMA seçeneği (güvenli/temkinli hareket)

Karar noktaları için:
- Hikayede belirtilen seçeneklere uygun alternatifler üret
- Örn: "iki yol" → "Sola giderim", "Sağa giderim", "Beklerim", "Geri dönerim"
- Örn: "kapı sesleri" → "Kapıyı açarım", "Sessizce yaklaşırım", "Beklerim", "Uzaklaşırım"

Hikayenin atmosferine ve mevcut durumuna uygun seçenekler üret.

JSON formatında döndür:
{
  "choices": [
    {"id": "1", "text": "Seçenek 1"},
    {"id": "2", "text": "Seçenek 2"},
    {"id": "3", "text": "Seçenek 3"},
    {"id": "4", "text": "Seçenek 4"}
  ]
}
''';

    final requestBody = {
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content':
              '''Sen uzman bir interaktif hikaye seçenekleri üreticisisin. 

Görevin: Verilen hikaye durumuna uygun, mantıklı ve çeşitli 4 seçenek üretmek.

KURALLARIN:
- Her seçenek hikayenin mevcut durumu ile bağlantılı olmalı
- 4 seçenek 4 farklı yaklaşım sunmalı (aksiyon, diplomasi, gözlem, savunma)
- Seçenekler kısa ve net olmalı
- 1. şahıs olarak yazılmalı
- JSON formatında döndürmelisin

Kaliteli, mantıklı ve hikayeye uygun seçenekler üret.''',
        },
        {'role': 'user', 'content': choicePrompt},
      ],
      'temperature': 0.9, // Seçenekler için daha yaratıcı
      'max_tokens': 400, // Seçenekler için yeterli alan
      'top_p': 0.95,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    try {
      _logger.debug('📤 Seçenek üretme API isteği gönderiliyor');

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
        _logger.debug('✅ Seçenek API yanıtı başarıyla alındı');

        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null &&
            responseData['choices'][0]['message']['content'] != null) {
          final content = responseData['choices'][0]['message']['content'];

          // JSON'u parse et
          try {
            final jsonData = jsonDecode(content);
            if (jsonData['choices'] != null && jsonData['choices'] is List) {
              final choices = <Choice>[];
              for (var choiceData in jsonData['choices']) {
                choices.add(
                  Choice(
                    id: choiceData['id'] ?? 'unknown',
                    text: choiceData['text'] ?? 'Bilinmeyen seçenek',
                  ),
                );
              }

              _logger.debug('✅ ${choices.length} seçenek başarıyla üretildi');
              return choices;
            }
          } catch (e) {
            _logger.error('❌ Seçenek JSON parse hatası', e);
          }

          // JSON parse başarısızsa, manuel olarak seçenekler oluştur
          return _createFallbackChoices();
        } else {
          _logger.error(
            '❌ Seçenek API yanıtında metin bulunamadı',
            responseData,
          );
          return _createFallbackChoices();
        }
      } else {
        final errorData = jsonDecode(response.body);
        _logger.error(
          '❌ Seçenek API Hatası: ${response.statusCode}',
          errorData,
        );
        return _createFallbackChoices();
      }
    } catch (e, stackTrace) {
      _logger.error('💥 Seçenek üretme API isteği başarısız', e, stackTrace);
      return _createFallbackChoices();
    }
  }

  /// Yedek seçenekler oluşturur (API hatası durumunda)
  List<Choice> _createFallbackChoices() {
    _logger.warning('⚠️ Yedek seçenekler oluşturuluyor');
    return [
      Choice(id: '1', text: 'Hikayeyi devam ettir'),
      Choice(id: '2', text: 'Farklı bir yöne git'),
      Choice(id: '3', text: 'Detayları araştır'),
      Choice(id: '4', text: 'Yeni bir maceraya atıl'),
    ];
  }
}
