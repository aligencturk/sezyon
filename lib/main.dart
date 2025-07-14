import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    
    return MaterialApp(
      title: languageService.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.deepPurple.shade600,
              width: 2,
            ),
          ),
        ),
      ),
      home: const CategorySelectionScreen(),
    );
  }
}
