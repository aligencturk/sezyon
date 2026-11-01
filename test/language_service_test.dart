import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sezyon/services/language_service.dart';
import 'package:sezyon/services/logger_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LoggerService().initialize();

  group('LanguageService.possessive', () {
    final service = LanguageService();

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await service.setLanguage(AppLanguage.turkish);
    });

    test('Türkçe: ünlü uyumuna göre ek alır', () {
      expect(service.possessive('Ali'), "Ali'nin");
      expect(service.possessive('Alı'), "Alı'nın");
      expect(service.possessive('Ahmet'), "Ahmet'in");
      expect(service.possessive('Mustafa'), "Mustafa'nın");
      expect(service.possessive('Orhan'), "Orhan'ın");
      expect(service.possessive('Su'), "Su'nun");
      expect(service.possessive('Gül'), "Gül'ün");
      expect(service.possessive('Ömer'), "Ömer'in");
      expect(service.possessive('Işık'), "Işık'ın");
      expect(service.possessive('İlker'), "İlker'in");
    });

    test('Boş isim olduğu gibi döner', () {
      expect(service.possessive(''), '');
    });

    test("İngilizce: 's ekler", () async {
      await service.setLanguage(AppLanguage.english);
      expect(service.possessive('Ali'), "Ali's");
    });
  });
}
