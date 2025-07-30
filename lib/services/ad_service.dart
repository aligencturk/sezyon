import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final LoggerService _logger = LoggerService();
  bool _isInitialized = false;

  // Test ID'leri - Gerçek uygulamada bunları .env dosyasından alacaksınız
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Gerçek ID'ler için .env dosyasından alınacak
  String get bannerAdUnitId => dotenv.env['BANNER_AD_UNIT_ID'] ?? _testBannerAdUnitId;
  String get interstitialAdUnitId => dotenv.env['INTERSTITIAL_AD_UNIT_ID'] ?? _testInterstitialAdUnitId;
  String get rewardedAdUnitId => dotenv.env['REWARDED_AD_UNIT_ID'] ?? _testRewardedAdUnitId;

  /// AdMob'u başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _logger.info('✅ AdMob başarıyla başlatıldı');
    } catch (e) {
      _logger.error('❌ AdMob başlatılırken hata oluştu', e);
    }
  }

  /// Banner reklam oluştur
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _logger.info('✅ Banner reklam yüklendi');
        },
        onAdFailedToLoad: (ad, error) {
          _logger.error('❌ Banner reklam yüklenemedi', error);
          ad.dispose();
        },
        onAdOpened: (ad) {
          _logger.info('📱 Banner reklam açıldı');
        },
        onAdClosed: (ad) {
          _logger.info('🔒 Banner reklam kapandı');
        },
      ),
    );
  }

  /// Interstitial reklam oluştur
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  Future<void> loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
            _logger.info('✅ Interstitial reklam yüklendi');
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _isInterstitialAdReady = false;
                _interstitialAd = null;
                _logger.info('🔒 Interstitial reklam kapandı');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _logger.error('❌ Interstitial reklam gösterilemedi', error);
                ad.dispose();
                _isInterstitialAdReady = false;
                _interstitialAd = null;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _logger.error('❌ Interstitial reklam yüklenemedi', error);
            _isInterstitialAdReady = false;
          },
        ),
      );
    } catch (e) {
      _logger.error('❌ Interstitial reklam yüklenirken hata', e);
    }
  }

  /// Interstitial reklam göster
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      _logger.warning('⚠️ Interstitial reklam hazır değil, yükleniyor...');
      await loadInterstitialAd();
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      _logger.error('❌ Interstitial reklam gösterilirken hata', e);
      return false;
    }
  }

  /// Rewarded reklam oluştur
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  Future<void> loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
            _logger.info('✅ Rewarded reklam yüklendi');
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _isRewardedAdReady = false;
                _rewardedAd = null;
                _logger.info('🔒 Rewarded reklam kapandı');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _logger.error('❌ Rewarded reklam gösterilemedi', error);
                ad.dispose();
                _isRewardedAdReady = false;
                _rewardedAd = null;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _logger.error('❌ Rewarded reklam yüklenemedi', error);
            _isRewardedAdReady = false;
          },
        ),
      );
    } catch (e) {
      _logger.error('❌ Rewarded reklam yüklenirken hata', e);
    }
  }

  /// Rewarded reklam göster
  Future<bool> showRewardedAd({
    required Function() onRewarded,
    required Function() onFailed,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      _logger.warning('⚠️ Rewarded reklam hazır değil, yükleniyor...');
      await loadRewardedAd();
      onFailed();
      return false;
    }

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          _logger.info('🎁 Kullanıcı ödül kazandı: ${reward.amount} ${reward.type}');
          onRewarded();
        },
      );
      return true;
    } catch (e) {
      _logger.error('❌ Rewarded reklam gösterilirken hata', e);
      onFailed();
      return false;
    }
  }

  /// Reklamları temizle
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _logger.info('🧹 Reklam servisi temizlendi');
  }

  /// Reklam durumunu kontrol et
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;
} 