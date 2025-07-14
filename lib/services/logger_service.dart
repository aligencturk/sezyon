import 'package:logger/logger.dart';

/// Uygulama genelinde kullanılacak logger servisi
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  late final Logger _logger;

  /// Logger'ı başlatır
  void initialize() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: Level.debug,
    );
    
    info('🚀 Logger servisi başlatıldı');
  }

  /// Bilgi mesajı loglar
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Uyarı mesajı loglar
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Hata mesajı loglar
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Debug mesajı loglar
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// API isteklerini loglar
  void apiRequest(String method, String url, [Map<String, dynamic>? data]) {
    info('🌐 API İsteği: $method $url', data);
  }

  /// API yanıtlarını loglar
  void apiResponse(String url, int statusCode, [dynamic response]) {
    if (statusCode >= 200 && statusCode < 300) {
      info('✅ API Yanıtı: $url ($statusCode)', response);
    } else {
      error('❌ API Hatası: $url ($statusCode)', response);
    }
  }

  /// Oyun olaylarını loglar
  void gameEvent(String event, [Map<String, dynamic>? data]) {
    info('🎮 Oyun Olayı: $event', data);
  }
} 