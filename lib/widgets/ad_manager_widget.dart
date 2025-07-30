import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import 'banner_ad_widget.dart';

class AdManagerWidget extends StatefulWidget {
  final Widget child;
  final bool showBannerAtBottom;
  final bool showBannerAtTop;
  final VoidCallback? onInterstitialAdShown;
  final VoidCallback? onRewardedAdShown;

  const AdManagerWidget({
    super.key,
    required this.child,
    this.showBannerAtBottom = true,
    this.showBannerAtTop = false,
    this.onInterstitialAdShown,
    this.onRewardedAdShown,
  });

  @override
  State<AdManagerWidget> createState() => _AdManagerWidgetState();
}

class _AdManagerWidgetState extends State<AdManagerWidget> {
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  void _loadAds() {
    // Interstitial ve rewarded reklamları önceden yükle
    _adService.loadInterstitialAd();
    _adService.loadRewardedAd();
  }

  /// Interstitial reklam göster
  Future<void> showInterstitialAd() async {
    final success = await _adService.showInterstitialAd();
    if (success) {
      widget.onInterstitialAdShown?.call();
    }
  }

  /// Rewarded reklam göster
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    await _adService.showRewardedAd(
      onRewarded: () {
        onRewarded();
        widget.onRewardedAdShown?.call();
      },
      onFailed: onFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Üst banner reklam
          if (widget.showBannerAtTop)
            const BannerAdWidget(
              height: 50,
              margin: EdgeInsets.only(top: 8),
            ),
          
          // Ana içerik
          Expanded(
            child: widget.child,
          ),
          
          // Alt banner reklam
          if (widget.showBannerAtBottom)
            const BannerAdWidget(
              height: 50,
              margin: EdgeInsets.only(bottom: 8),
            ),
        ],
      ),
    );
  }
} 