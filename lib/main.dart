import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sezyon/screens/splash_screen.dart';
import 'screens/category_selection_screen.dart';
import 'services/logger_service.dart';
import 'services/language_service.dart';
import 'services/audio_service.dart';

/// Ana uygulama giriş noktası
Future<void> main() async {
  // Flutter'ın başlatılmasını bekle
  WidgetsFlutterBinding.ensureInitialized();
  
  // Logger'ı başlat
  LoggerService().initialize();
  final logger = LoggerService();
  
  try {
    // .env dosyasını yükle
    await dotenv.load(fileName: ".env");
    logger.info('✅ .env dosyası başarıyla yüklendi');
  } catch (e) {
    logger.warning('⚠️ .env dosyası yüklenemedi', e);
    print('Lütfen proje kökünde .env dosyasının bulunduğundan emin olun.');
  }
  
  // Dil servisini başlat
  try {
    await LanguageService().loadLanguagePreference();
    logger.info('🌍 Dil servisi başlatıldı');
  } catch (e) {
    logger.error('Dil servisi başlatılırken hata', e);
  }
  
  // Audio servisini başlat
  try {
    logger.info('🎵 Audio servisi başlatıldı');
  } catch (e) {
    logger.error('Audio servisi başlatılırken hata', e);
  }
  
  runApp(const SezyonApp());
}

/// Ana uygulama widget'ı
class SezyonApp extends StatefulWidget {
  const SezyonApp({super.key});

  @override
  State<SezyonApp> createState() => _SezyonAppState();
}

class _SezyonAppState extends State<SezyonApp> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _audioService.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        _audioService.onAppResumed();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final darkTheme = ThemeData.dark();

    return MaterialApp(
      title: 'Sezyon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF6A1B9A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8E24AA), // Ana butonlar, aktif elemanlar
          secondary: Color(0xFF4A148C), // İkincil vurgu, AI mesajları
          background: Color(0xFF121212), // Ana arka plan
          surface: Color(0xFF1E1E1E), // Kartlar, diyaloglar
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.sourceSans3TextTheme(darkTheme.textTheme)
            .copyWith(
          displayLarge: GoogleFonts.merriweather(textStyle: textTheme.displayLarge),
          displayMedium: GoogleFonts.merriweather(textStyle: textTheme.displayMedium),
          displaySmall: GoogleFonts.merriweather(textStyle: textTheme.displaySmall),
          headlineLarge: GoogleFonts.merriweather(textStyle: textTheme.headlineLarge),
          headlineMedium: GoogleFonts.merriweather(textStyle: textTheme.headlineMedium),
          headlineSmall: GoogleFonts.merriweather(textStyle: textTheme.headlineSmall),
          titleLarge: GoogleFonts.merriweather(textStyle: textTheme.titleLarge),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.merriweather(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF8E24AA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
