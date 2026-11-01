import '../services/language_service.dart';

/// Oyun kategorileri enum'u
enum GameCategory {
  war('war'),
  sciFi('sciFi'),
  fantasy('fantasy'),
  mystery('mystery'),
  historical('historical'),
  apocalypse('apocalypse');

  const GameCategory(this.key);
  final String key;

  /// Kategori adını döndürür
  String get displayName {
    final languageService = LanguageService();
    return languageService.getCategoryName(key);
  }


  /// Kategori için açıklama metni oluşturur
  String getDescription(String languageCode) {
    bool isTurkish = languageCode == 'tr';
    switch (this) {
      case GameCategory.war:
        return isTurkish
            ? 'Savaşın acımasız gerçekleriyle yüzleş. Vereceğin kararlar cephenin kaderini belirleyecek.'
            : 'Face the brutal realities of war. Your decisions will determine the fate of the front line.';
      case GameCategory.sciFi:
        return isTurkish
            ? 'Yıldızların ötesinde, bilinmeyen tehlikeler ve kadim sırlar seni bekliyor.'
            : 'Beyond the stars, unknown dangers and ancient secrets await you.';
      case GameCategory.fantasy:
        return isTurkish
            ? 'Büyünün ve çeliğin konuştuğu topraklarda efsaneni yaz. Ejderhalar gökyüzünde süzülüyor.'
            : 'Write your legend in lands where magic and steel speak. Dragons soar in the sky.';
      case GameCategory.mystery:
        return isTurkish
            ? 'Her köşesi sisle kaplı bu şehirde hiçbir şey göründüğü gibi değil. İpuçlarını takip et.'
            : 'In this fog-covered city, nothing is as it seems. Follow the clues.';
      case GameCategory.historical:
        return isTurkish
            ? 'Tarihin tozlu sayfalarında bir yolculuğa çık. Geçmişi yeniden şekillendirmek senin elinde.'
            : 'Embark on a journey through the dusty pages of history. It is in your hands to reshape the past.';
      case GameCategory.apocalypse:
        return isTurkish
            ? 'Yıkılmış bir dünyanın enkazında hayatta kalmaya çalış. Tehlike her an, her yerde.'
            : 'Try to survive in the wreckage of a ruined world. Danger is anytime, anywhere.';
    }
  }
}
