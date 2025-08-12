import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../features/quiz/application/quiz_providers.dart';
import '../services/ad_service.dart';
import '../utils/logger.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadAd();
  }

  void _maybeLoadAd() {
    final isPro = ref.read(proStatusProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );
    if (isPro) return;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Logger.debug('BannerAd loaded successfully');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          Logger.error('BannerAd failed to load', error);
          setState(() {
            _isAdLoaded = false;
            _bannerAd = null;
          });
        },
      ),
    );
    ad.load();
    _bannerAd = ad;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proAsync = ref.watch(proStatusProvider);
    final isPro = proAsync.when(
      data: (v) => v,
      loading: () => false,
      error: (_, __) => false,
    );
    if (isPro) return const SizedBox.shrink();

    final ad = _bannerAd;
    // Always reserve space for the banner to ensure it becomes visible when loaded
    if (ad == null || !_isAdLoaded) {
      return const SizedBox(height: 50);
    }

    return SafeArea(
      top: false,
      child: Container(
        height: ad.size.height.toDouble(),
        width: double.infinity,
        alignment: Alignment.center,
        child: AdWidget(ad: ad),
      ),
    );
  }
}


