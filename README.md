# 🎮 Flutter RPG Oyunu

Flutter ile geliştirilmiş metin tabanlı RPG (Rol Yapma) oyunu. Gemini 2.0 Flash AI ile güçlendirilmiş interaktif hikaye deneyimi.

## ✨ Özellikler

- 🌍 **Çok Dilli Destek**: Türkçe ve İngilizce
- 🤖 **AI Destekli Hikayeler**: Gemini 2.0 Flash ile dinamik hikaye üretimi
- 🎯 **4 Farklı Kategori**: Savaş, Bilim Kurgu, Tarih, Fantastik
- 💬 **Sohbet Arayüzü**: WhatsApp benzeri kullanıcı dostu arayüz
- ⚙️ **Ayarlar Sistemi**: Dil değiştirme ve kişiselleştirme
- 🐛 **Gelişmiş Hata Yönetimi**: Detaylı loglama sistemi

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK (≥3.8.1)
- Dart SDK
- Android Studio veya VS Code
- Gemini AI API Anahtarı

### Adımlar

1. **Projeyi klonlayın:**
   ```bash
   git clone https://github.com/aligencturk/sezyon.git
   cd sezyon
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Çevre değişkenlerini ayarlayın:**
   - `.env.example` dosyasını `.env` olarak kopyalayın
   - Gemini AI API anahtarınızı ekleyin:
   ```bash
   cp .env.example .env
   ```
   
   `.env` dosyasını düzenleyin:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   GEMINI_MODEL=gemini-2.0-flash
   ```

4. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

## 🔑 Gemini AI API Anahtarı Alma

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. Google hesabınızla giriş yapın
3. "Create API Key" butonuna tıklayın
4. Oluşturulan anahtarı `.env` dosyasına ekleyin

## 🎯 Kullanım

1. **Kategori Seçimi**: Ana ekranda istediğiniz oyun kategorisini seçin
2. **Dil Ayarı**: Sağ üstteki ayarlar simgesinden dili değiştirin
3. **Hikaye Oynama**: AI'ın oluşturduğu hikayeye yanıt verin
4. **Etkileşim**: Seçenekleri seçin veya kendi cevabınızı yazın

## 📱 Ekran Görüntüleri

### Ana Ekran
- Kategori seçimi
- Ayarlar erişimi

### Hikaye Ekranı
- AI ile sohbet
- Mesaj geçmişi
- Kullanıcı giriş alanı

### Ayarlar Ekranı
- Dil değiştirme
- Uygulama bilgileri

## 🛠 Teknoloji Yığını

- **Framework**: Flutter
- **Dil**: Dart
- **AI**: Gemini 2.0 Flash API
- **Durum Yönetimi**: StatefulWidget
- **Yerel Depolama**: SharedPreferences
- **HTTP İstekleri**: http paketi
- **Çevre Değişkenleri**: flutter_dotenv
- **Loglama**: logger paketi

## 📁 Proje Yapısı

```
lib/
├── models/
│   ├── game_category.dart    # Oyun kategorileri
│   └── message.dart          # Mesaj modeli
├── screens/
│   ├── category_selection_screen.dart  # Ana ekran
│   ├── story_screen.dart               # Hikaye ekranı
│   └── settings_screen.dart            # Ayarlar ekranı
├── services/
│   ├── gemini_service.dart   # AI API iletişimi
│   ├── language_service.dart # Dil yönetimi
│   └── logger_service.dart   # Loglama sistemi
└── main.dart                 # Uygulama giriş noktası
```

## 🌍 Desteklenen Diller

- 🇹🇷 **Türkçe**: Tam uygulama desteği
- 🇺🇸 **İngilizce**: Tam uygulama desteği

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👨‍💻 Geliştirici

**Ali Genç Türk**
- GitHub: [@aligencturk](https://github.com/aligencturk)

## 🙏 Teşekkürler

- Google AI - Gemini 2.0 Flash API
- Flutter Team - Harika framework
- Dart Team - Güçlü programlama dili

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
