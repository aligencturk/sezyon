# Ses Dosyaları

Bu klasör oyun için müzik ve ses efektlerini içerir.

## Desteklenen Formatlar
- **OGG** ✅ (Önerilen - daha küçük dosya boyutu)
- MP3
- WAV
- M4A

## Dosya Yapısı

### Müzik Dosyaları
- `ana-menü.ogg` - Ana menü arka plan müziği ✅

### Kategori Müzikleri
- `savaş.ogg` - Savaş kategorisi müziği
- `bilimkurgu.ogg` - Bilim Kurgu kategorisi müziği
- `fantastik.ogg` - Fantastik kategorisi müziği
- `gizem.ogg` - Gizem kategorisi müziği ✅
- `tarihi.ogg` - Tarihi kategorisi müziği
- `kıyamet.ogg` - Kıyamet Sonrası kategorisi müziği

### Opsiyonel Müzikler
- `victory_music.mp3` - Zafer müziği
- `defeat_music.mp3` - Yenilgi müziği

### Ses Efektleri
- `button_click.wav` - Buton tıklama sesi
- `page_turn.wav` - Sayfa çevirme sesi
- `notification.wav` - Bildirim sesi
- `success.wav` - Başarı sesi
- `error.wav` - Hata sesi

## Kullanım

Müzik dosyalarını bu klasöre ekledikten sonra, AudioService ile çalabilirsiniz:

```dart
// Arka plan müziği çal
await AudioService().playBackgroundMusic('audio/ana-menü.ogg');

// Kategori müziği çal
await AudioService().playCategoryMusic('gizem'); // gizem.ogg çalar

// Ses efekti çal
await AudioService().playSoundEffect('audio/button_click.ogg');
```

## Müzik Akışı

1. **Uygulama Açılışı**: `ana-menü.ogg` çalmaya başlar
2. **Kategori Seçimi**: Buton tıklama sesi + kategori müziğine geçiş
3. **Oyun Sırasında**: `[türkçe_kategori].ogg` çalar (varsa) veya ana menü müziği devam eder
4. **Oyun Bitişi**: Ana menü müziğine yumuşak geçiş ile geri dönüş

## Yumuşak Geçiş Özellikleri

- **Geçiş Süresi**: 1 saniye
- **Fade Out**: Mevcut müzik yavaşça azalır
- **Fade In**: Yeni müzik yavaşça artar
- **Loop Modu**: Tüm müzikler sürekli çalar
- **41 Saniyelik Müzik**: Otomatik olarak loop'a alınır

## Kategori Müzik Önerileri

- **Savaş**: Dramatik, savaş temalı müzik
- **Bilim Kurgu**: Futuristik, uzay temalı müzik  
- **Fantastik**: Epik, büyülü müzik
- **Gizem**: Gizemli, kasvetli müzik
- **Tarihi**: Tarihi dönem müziği
- **Kıyamet Sonrası**: Korkutucu, tehlikeli müzik

## Not
- Dosya boyutları küçük tutulmalıdır (mobil uygulama için)
- Telif hakkı olmayan müzikler kullanılmalıdır
- Ses kalitesi ile dosya boyutu arasında denge kurulmalıdır
- **Arka Plan Kontrolü**: Uygulama arka plana alındığında müzik otomatik olarak durur 