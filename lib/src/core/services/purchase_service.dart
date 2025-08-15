import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  // RevenueCat API keys - Replace with your actual keys from RevenueCat Dashboard
  // https://app.revenuecat.com/ -> API Keys section
  static const String _appleApiKey = 'appl_YOUR_APPLE_API_KEY_HERE'; // iOS API Key
  static const String _googleApiKey = 'goog_MyxwvgmwPQmkKzwjZlWlIunGURl'; // Android API Key
  
  // Google Play Store Product ID
  static const String _monthlyProductId = 'premium_monthly_subscription:premium-monthly';
  
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  bool _isInitialized = false;
  bool _isPro = false;
  final StreamController<bool> _proStatusController = StreamController<bool>.broadcast();

  Stream<bool> get proStatusStream {
    return _proStatusController.stream;
  }
  bool get isPro {
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
      // In debug builds, enable verbose logging to verify SDK connection
      assert(() {
        Purchases.setLogLevel(LogLevel.debug);
        return true;
      }());

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
        if (_googleApiKey == 'goog_MyxwvgmwPQmkKzwjZlWlIunGURl') {
          configuration = PurchasesConfiguration(_googleApiKey);
        } else {
          debugPrint('Google API key not configured, skipping RevenueCat initialization');
          _isPro = false;
          _isInitialized = true;
          _proStatusController.add(false);
          return;
        }
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
      
      // Log available offerings for debugging
      debugPrint('Available offerings: ${offerings.all.keys.join(', ')}');
      
      // Filter offerings to only include our configured products
      final filteredOfferings = offerings.all.values.where((offering) {
        final hasMonthly = offering.monthly?.storeProduct.identifier == _monthlyProductId;
        return hasMonthly;
      }).toList();
      
      if (filteredOfferings.isEmpty) {
        debugPrint('No offerings found with configured product ID: $_monthlyProductId');
        return offerings.all.values.toList(); // Return all if filtering fails
      }
      
      return filteredOfferings;
    } catch (e) {
      debugPrint('Failed to fetch offerings: $e');
      return [];
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      // Validate package before purchase
      final productId = package.storeProduct.identifier;
      if (productId != _monthlyProductId) {
        debugPrint('Invalid product ID: $productId. Expected: $_monthlyProductId');
        return false;
      }
      
      debugPrint('Purchasing package: ${package.identifier} with product: $productId');
      final purchaseResult = await Purchases.purchasePackage(package);
      
      // Check if purchase was successful
      if (purchaseResult.customerInfo.entitlements.active.containsKey('pro')) {
        _isPro = true;
        _proStatusController.add(true);
        debugPrint('Purchase successful! User is now Pro');
        return true;
      }
      
      debugPrint('Purchase completed but Pro status not activated');
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

  /// Get subscription status with detailed info
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.active.containsKey('pro');
      
      if (isPro) {
        final entitlement = customerInfo.entitlements.active['pro']!;
        final productId = entitlement.productIdentifier;
        final isMonthly = productId == _monthlyProductId;
        
        return {
          'isPro': true,
          'expiresDate': entitlement.expirationDate?.toString(),
          'productId': productId,
          'productType': isMonthly ? 'monthly' : 'unknown',
          'willRenew': entitlement.willRenew,
          'isMonthly': isMonthly,
          'isYearly': false,
        };
      }
      
      return {
        'isPro': false,
        'expiresDate': null,
        'productId': null,
        'productType': null,
        'willRenew': false,
        'isMonthly': false,
        'isYearly': false,
      };
    } catch (e) {
      debugPrint('Failed to get subscription status: $e');
      return {
        'isPro': false,
        'expiresDate': null,
        'productId': null,
        'productType': null,
        'willRenew': false,
        'isMonthly': false,
        'isYearly': false,
      };
    }
  }

  /// Dispose resources
  void dispose() {
    _proStatusController.close();
  }
}
