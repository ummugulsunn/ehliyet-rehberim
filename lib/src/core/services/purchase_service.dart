import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  // RevenueCat API keys - Replace with your actual keys from RevenueCat Dashboard
  // https://app.revenuecat.com/ -> API Keys section
  static const String _appleApiKey = 'appl_YOUR_APPLE_API_KEY_HERE'; // iOS API Key
  static const String _googleApiKey = 'google_YOUR_GOOGLE_API_KEY_HERE'; // Android API Key
  
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  bool _isInitialized = false;
  bool _isPro = false;
  final StreamController<bool> _proStatusController = StreamController<bool>.broadcast();

  Stream<bool> get proStatusStream {
    // --- START OF NEW CODE ---
    // Developer Override: If in debug mode, return a stream that always says "Pro".
    if (kDebugMode) {
      return Stream<bool>.value(true);
    }
    // --- END OF NEW CODE ---
    return _proStatusController.stream;
  }
  bool get isPro {
    // --- START OF NEW CODE ---
    // Developer Override: If in debug mode, always return true for easy testing.
    if (kDebugMode) {
      return true;
    }
    // --- END OF NEW CODE ---
    try {
      return _isPro;
    } catch (e) {
      debugPrint('Error getting isPro: $e');
      return false;
    }
  }

  /// Initialize RevenueCat with API keys
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Configure RevenueCat
      PurchasesConfiguration configuration;
      
      // Use different API keys for iOS and Android
      if (Platform.isIOS) {
        if (_appleApiKey == 'appl_YOUR_APPLE_API_KEY_HERE') {
          debugPrint('Apple API key not configured, skipping RevenueCat initialization');
          _isPro = false;
          _isInitialized = true;
          _proStatusController.add(false);
          return;
        }
        configuration = PurchasesConfiguration(_appleApiKey);
      } else if (Platform.isAndroid) {
        if (_googleApiKey == 'google_YOUR_GOOGLE_API_KEY_HERE') {
          debugPrint('Google API key not configured, skipping RevenueCat initialization');
          _isPro = false;
          _isInitialized = true;
          _proStatusController.add(false);
          return;
        }
        configuration = PurchasesConfiguration(_googleApiKey);
      } else {
        throw UnsupportedError('Platform not supported');
      }

      await Purchases.configure(configuration);
      
      // Check if user is already a pro subscriber
      await _checkProStatus();
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize RevenueCat: $e');
      // Don't rethrow, just set as not pro
      _isPro = false;
      _proStatusController.add(false);
      _isInitialized = true;
    }
  }

  /// Check if the user has pro status
  Future<void> _checkProStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPro = customerInfo.entitlements.active.containsKey('pro');
      _proStatusController.add(_isPro);
    } catch (e) {
      debugPrint('Failed to check pro status: $e');
      _isPro = false;
      _proStatusController.add(false);
    }
  }

  /// Fetch available offerings (subscription packages)
  Future<List<Offering>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.all.values.toList();
    } catch (e) {
      debugPrint('Failed to fetch offerings: $e');
      return [];
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      
      // Check if purchase was successful
      if (purchaseResult.customerInfo.entitlements.active.containsKey('pro')) {
        _isPro = true;
        _proStatusController.add(true);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to purchase package: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _isPro = customerInfo.entitlements.active.containsKey('pro');
      _proStatusController.add(_isPro);
      return _isPro;
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      return false;
    }
  }

  /// Get current customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _proStatusController.close();
  }
}
