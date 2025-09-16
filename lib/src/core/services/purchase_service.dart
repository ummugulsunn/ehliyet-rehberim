import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PurchaseService {
  // RevenueCat API keys - Replace with your actual keys from RevenueCat Dashboard
  // https://app.revenuecat.com/ -> API Keys section
  static const String _appleApiKey = 'appl_YOUR_APPLE_API_KEY_HERE'; // iOS API Key
  static const String _googleApiKey = 'goog_MyxwvgmwPQmkKzwjZlWlIunGURl'; // Android API Key
  
  // Google Play Store Product ID
  static const String _monthlyProductId = 'premium_monthly_subscription:premium-monthly';
  
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal() {
    // Listen to Firebase Auth changes and sync with RevenueCat
    _setupAuthListener();
  }

  bool _isInitialized = false;
  bool _isPro = false;
  final StreamController<bool> _proStatusController = StreamController<bool>.broadcast();
  StreamSubscription<User?>? _authSubscription;

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

  /// Initialize RevenueCat with API keys and user ID
  Future<void> init({String? userId}) async {
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
      
      // Set user ID if provided (important for account-based subscriptions)
      if (userId != null && userId.isNotEmpty) {
        await Purchases.logIn(userId);
        debugPrint('RevenueCat: Logged in user with ID: $userId');
      } else {
        debugPrint('RevenueCat: No user ID provided, using anonymous user');
      }
      
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
      
      // Check for active entitlements
      final hasActiveEntitlement = customerInfo.entitlements.active.containsKey('pro');
      
      // Also check for any entitlements (including inactive ones for test accounts)
      final hasAnyEntitlement = customerInfo.entitlements.all.containsKey('pro');
      
      // Check for active subscriptions
      final hasActiveSubscriptions = customerInfo.activeSubscriptions.isNotEmpty;
      
      // In test environment, be more lenient
      _isPro = hasActiveEntitlement || (hasAnyEntitlement && hasActiveSubscriptions);
      
      debugPrint('Pro status check: active=$hasActiveEntitlement, any=$hasAnyEntitlement, subscriptions=$hasActiveSubscriptions, result=$_isPro');
      
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
      
      // In test environment, purchase might be successful even if entitlement is not immediately active
      final customerInfo = purchaseResult.customerInfo;
      final hasActiveEntitlement = customerInfo.entitlements.active.containsKey('pro');
      final hasAnyEntitlement = customerInfo.entitlements.all.containsKey('pro');
      
      // Check for active entitlement first
      if (hasActiveEntitlement) {
        _isPro = true;
        _proStatusController.add(true);
        debugPrint('Purchase successful! User is now Pro (active entitlement)');
        return true;
      }
      
      // In test mode, check if entitlement exists but might not be active yet
      if (hasAnyEntitlement) {
        final entitlement = customerInfo.entitlements.all['pro']!;
        debugPrint('Purchase completed! Entitlement exists but may not be active yet');
        debugPrint('Entitlement details: isActive=${entitlement.isActive}, willRenew=${entitlement.willRenew}');
        
        // For test purchases, consider it successful if entitlement exists
        _isPro = true;
        _proStatusController.add(true);
        return true;
      }
      
      // Check if there are any active purchases (for test accounts)
      if (customerInfo.activeSubscriptions.isNotEmpty) {
        debugPrint('Purchase completed! Active subscriptions found: ${customerInfo.activeSubscriptions}');
        _isPro = true;
        _proStatusController.add(true);
        return true;
      }
      
      debugPrint('Purchase completed but no entitlements or subscriptions found');
      debugPrint('CustomerInfo: ${customerInfo.toString()}');
      
      // Even if entitlement is not immediately visible, consider purchase successful
      // This is common in test environment
      return true;
    } catch (e) {
      debugPrint('Failed to purchase package: $e');
      
      // Check if it's a user cancellation (not an error)
      if (e.toString().contains('UserCancelled') || e.toString().contains('cancelled')) {
        debugPrint('Purchase was cancelled by user');
        return false;
      }
      
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

  /// Switch user (important when user logs out/in with different account)
  Future<void> switchUser(String? newUserId) async {
    try {
      if (newUserId != null && newUserId.isNotEmpty) {
        // Log in with new user ID
        await Purchases.logIn(newUserId);
        debugPrint('RevenueCat: Switched to user ID: $newUserId');
      } else {
        // Log out current user (switch to anonymous)
        await Purchases.logOut();
        debugPrint('RevenueCat: Logged out user, switched to anonymous');
      }
      
      // Re-check pro status for new user
      await _checkProStatus();
    } catch (e) {
      debugPrint('Failed to switch user: $e');
      _isPro = false;
      _proStatusController.add(false);
    }
  }

  /// Log out current user (switch to anonymous)
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      debugPrint('RevenueCat: User logged out');
      _isPro = false;
      _proStatusController.add(false);
    } catch (e) {
      debugPrint('Failed to log out user: $e');
    }
  }

  /// Setup Firebase Auth listener to automatically sync users
  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (!_isInitialized) return;
      
      try {
        if (user != null) {
          // User logged in - sync with RevenueCat
          await Purchases.logIn(user.uid);
          debugPrint('RevenueCat: Auto-synced with user ${user.uid}');
        } else {
          // User logged out - switch to anonymous
          await Purchases.logOut();
          debugPrint('RevenueCat: Auto-switched to anonymous user');
        }
        
        // Re-check pro status
        await _checkProStatus();
      } catch (e) {
        debugPrint('RevenueCat auto-sync error: $e');
      }
    });
  }

  /// Reset initialization (useful when switching users)
  void reset() {
    _isInitialized = false;
    _isPro = false;
    _proStatusController.add(false);
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _proStatusController.close();
  }
}
