import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton service for managing Google Mobile Ads
/// Handles banner, interstitial, and rewarded ads
class AdService {
  static final AdService _instance = AdService._internal();
  static AdService get instance => _instance;
  
  AdService._internal();

  /// Test ad unit IDs (will be replaced with real ones for production)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  /// Production ad unit IDs (Ehliyet Rehberim - TurkmenApps)
  static const String _prodBannerAdUnitId = 'ca-app-pub-2163842474515875/8092900320';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-2163842474515875/1527491971';
  static const String _prodRewardedAdUnitId = 'ca-app-pub-2163842474515875/3581410878';

  /// Current ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  /// Ad loading states
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  bool _isBannerHidden = false; // User can hide banner ad

  /// Initialize Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('AdMob initialized successfully');
      
      // Pre-load ads
      _loadBannerAd();
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  /// Get appropriate ad unit IDs based on debug/release mode
  String get _bannerAdUnitId => kDebugMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  String get _interstitialAdUnitId => kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  String get _rewardedAdUnitId => kDebugMode ? _testRewardedAdUnitId : _prodRewardedAdUnitId;

  /// Load banner ad
  void _loadBannerAd() {
    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.smartBanner, // Smart banner for better sizing
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            debugPrint('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            _bannerAd = null;
            ad.dispose();
            debugPrint('Banner ad failed to load: $error');
            
            // Retry after 30 seconds
            Future.delayed(const Duration(seconds: 30), () {
              _loadBannerAd();
            });
          },
          onAdOpened: (ad) => debugPrint('Banner ad opened'),
          onAdClosed: (ad) => debugPrint('Banner ad closed'),
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      debugPrint('Error creating banner ad: $e');
      _isBannerAdLoaded = false;
      _bannerAd = null;
    }
  }

  /// Load interstitial ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('Interstitial ad loaded');
          
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint('Interstitial ad failed to load: $error');
          
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  /// Load rewarded ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          debugPrint('Rewarded ad failed to load: $error');
          
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  /// Get banner ad widget
  Widget? getBannerAdWidget() {
    if (_bannerAd != null && _isBannerAdLoaded && !_isBannerHidden) {
      // Ensure we have valid dimensions
      final adSize = _bannerAd!.size;
      if (adSize.width > 0 && adSize.height > 0) {
        return SizedBox(
          width: adSize.width.toDouble(),
          height: adSize.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      } else {
        // Fallback to smart banner size if dimensions are invalid
        return SizedBox(
          width: 320, // Standard banner width
          height: 50,  // Standard banner height
          child: AdWidget(ad: _bannerAd!),
        );
      }
    }
    return null;
  }

  /// Hide banner ad
  void hideBannerAd() {
    _isBannerHidden = true;
    debugPrint('Banner ad hidden by user');
  }

  /// Show banner ad again
  void showBannerAd() {
    _isBannerHidden = false;
    debugPrint('Banner ad shown again');
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd({
    required VoidCallback onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) async {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          onAdDismissed();
          
          // Load next ad
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          debugPrint('Interstitial ad failed to show: $error');
          
          if (onAdFailedToShow != null) {
            onAdFailedToShow();
          } else {
            onAdDismissed(); // Fallback to continue user flow
          }
          
          // Load next ad
          _loadInterstitialAd();
        },
      );
      
      await _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready');
      onAdDismissed(); // Continue user flow even if ad not ready
    }
  }

  /// Show rewarded ad
  Future<void> showRewardedAd({
    required Function(RewardItem reward) onRewardEarned,
    required VoidCallback onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) async {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          onAdDismissed();
          
          // Load next ad
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          debugPrint('Rewarded ad failed to show: $error');
          
          if (onAdFailedToShow != null) {
            onAdFailedToShow();
          } else {
            onAdDismissed();
          }
          
          // Load next ad
          _loadRewardedAd();
        },
      );
      
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          onRewardEarned(reward);
        },
      );
    } else {
      debugPrint('Rewarded ad not ready');
      if (onAdFailedToShow != null) {
        onAdFailedToShow();
      } else {
        onAdDismissed();
      }
    }
  }

  /// Check if ads are available
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  /// Show interstitial ad if eligible (frequency capping)
  static Future<void> showInterstitialIfEligible() async {
    // Simple frequency capping - you can make this more sophisticated
    await AdService.instance.showInterstitialAd(
      onAdDismissed: () {
        debugPrint('Interstitial ad dismissed');
      },
      onAdFailedToShow: () {
        debugPrint('Interstitial ad failed to show');
      },
    );
  }

  /// Mark quiz completion for ad frequency tracking
  static Future<void> markQuizCompleted() async {
    // This can be used for more sophisticated frequency capping
    // For now, just log the completion
    debugPrint('Quiz completed - tracking for ad frequency');
  }

  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}