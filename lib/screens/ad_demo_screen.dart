import 'package:flutter/material.dart';
import '../widgets/ad_manager_widget.dart';
import '../services/ad_service.dart';

class AdDemoScreen extends StatefulWidget {
  const AdDemoScreen({super.key});

  @override
  State<AdDemoScreen> createState() => _AdDemoScreenState();
}

class _AdDemoScreenState extends State<AdDemoScreen> {
  final AdService _adService = AdService();
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return AdManagerWidget(
      showBannerAtBottom: true,
      showBannerAtTop: true,
      onInterstitialAdShown: () {
        setState(() {
          _statusMessage = 'Interstitial reklam gösterildi!';
        });
      },
      onRewardedAdShown: () {
        setState(() {
          _statusMessage = 'Rewarded reklam gösterildi!';
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reklam Demo'),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Reklam Entegrasyonu Demo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Durum mesajı
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Reklam durumu
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Reklam Durumu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusItem(
                            'Interstitial',
                            _adService.isInterstitialAdReady,
                          ),
                          _buildStatusItem(
                            'Rewarded',
                            _adService.isRewardedAdReady,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Reklam butonları
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _statusMessage = 'Interstitial reklam yükleniyor...';
                      });
                      
                      await _adService.loadInterstitialAd();
                      
                      setState(() {
                        _statusMessage = 'Interstitial reklam gösteriliyor...';
                      });
                      
                      final success = await _adService.showInterstitialAd();
                      
                      if (!success) {
                        setState(() {
                          _statusMessage = 'Interstitial reklam gösterilemedi';
                        });
                      }
                    },
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Interstitial Reklam Göster'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _statusMessage = 'Rewarded reklam yükleniyor...';
                      });
                      
                      await _adService.loadRewardedAd();
                      
                      setState(() {
                        _statusMessage = 'Rewarded reklam gösteriliyor...';
                      });
                      
                      await _adService.showRewardedAd(
                        onRewarded: () {
                          setState(() {
                            _statusMessage = '🎁 Ödül kazandınız! +100 puan';
                          });
                        },
                        onFailed: () {
                          setState(() {
                            _statusMessage = 'Rewarded reklam gösterilemedi';
                          });
                        },
                      );
                    },
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('Rewarded Reklam Göster'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Bilgi kartı
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Test Reklamları',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bu demo test reklamları kullanmaktadır. Gerçek uygulamada .env dosyasından gerçek reklam ID\'lerini alacaksınız.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isReady) {
    return Column(
      children: [
        Icon(
          isReady ? Icons.check_circle : Icons.error,
          color: isReady ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isReady ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
} 