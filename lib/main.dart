import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/category_selection_screen.dart';
import 'services/logger_service.dart';
import 'services/language_service.dart';

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
  
  runApp(const MyApp());
}

/// Ana uygulama widget'ı
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();

    // Karanlık ve şık bir tema oluştur
    final darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFFBB86FC),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFBB86FC), // Ana vurgu rengi (butonlar, ikonlar)
        secondary: Color(0xFF03DAC6), // İkincil vurgu rengi
        surface: Color(0xFF1E1E1E), // Kartların ve yüzeylerin rengi
        background: Color(0xFF121212), // Arka plan rengi
        error: Color(0xFFCF6679), // Hata rengi
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBB86FC),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
            fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.cinzel(
            fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: GoogleFonts.cinzel(
            fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
        titleLarge: GoogleFonts.lato(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: GoogleFonts.lato(fontSize: 16, color: Colors.white.withOpacity(0.87)),
        bodyMedium: GoogleFonts.lato(fontSize: 14, color: Colors.white.withOpacity(0.6)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        hintStyle: GoogleFonts.lato(color: Colors.white.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFBB86FC), width: 2),
        ),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: languageService.appTitle,
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: const CategorySelectionScreen(),
    );
  }
}
