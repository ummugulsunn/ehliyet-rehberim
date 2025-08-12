import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized ad management service. All ad logic goes here.
class AdService {
  AdService._();

  // Test Ad Unit IDs (official sample ids)
  static const String bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';

  static const String bannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  // Real Ad Unit IDs (comment out for now; replace before production)
  // static const String bannerAdUnitIdAndroid = '<YOUR_ANDROID_BANNER_ID>';
  // static const String interstitialAdUnitIdAndroid = '<YOUR_ANDROID_INTERSTITIAL_ID>';
  // static const String bannerAdUnitIdIOS = '<YOUR_IOS_BANNER_ID>';
  // static const String interstitialAdUnitIdIOS = '<YOUR_IOS_INTERSTITIAL_ID>';

  static int _quizCompletedCount = 0;
  static InterstitialAd? _interstitialAd;

  /// Returns a platform-appropriate banner ad unit id
  static String get bannerAdUnitId =>
      (defaultTargetPlatform == TargetPlatform.android)
          ? bannerAdUnitIdAndroid
          : bannerAdUnitIdIOS;

  /// Returns a platform-appropriate interstitial ad unit id
  static String get interstitialAdUnitId =>
      (defaultTargetPlatform == TargetPlatform.android)
          ? interstitialAdUnitIdAndroid
          : interstitialAdUnitIdIOS;

  /// Create and load a BannerAd
  static BannerAd createBannerAd({AdSize size = AdSize.banner}) {
    final ad = BannerAd(
      size: size,
      adUnitId: bannerAdUnitId,
      listener: const BannerAdListener(),
      request: const AdRequest(),
    );
    ad.load();
    return ad;
  }

  /// Prepare an interstitial ad
  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Mark a quiz as completed. Optionally trigger preload for next ad.
  static Future<void> markQuizCompleted() async {
    _quizCompletedCount++;
    // Opportunistically ensure we have an ad loaded for the next time
    if (_interstitialAd == null) {
      await loadInterstitialAd();
    }
  }

  /// Show interstitial every 3rd completion for non-pro users.
  /// Returns a Future that completes after the ad is dismissed or if not shown.
  static Future<void> showInterstitialIfEligible() async {
    if (_quizCompletedCount == 0 || _quizCompletedCount % 3 != 0) {
      return; // Not eligible yet
    }
    final ad = _interstitialAd;
    if (ad == null) {
      await loadInterstitialAd();
      return;
    }
    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        completer.complete();
        // Preload next
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        completer.complete();
      },
    );
    ad.show();
    await completer.future;
  }
}


