import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import 'connectivity_service.dart';
import 'error_tracking_service.dart';
import 'user_progress_service.dart';
import '../../features/auth/domain/auth_error.dart';
import '../../features/auth/domain/auth_state_model.dart';
import '../../features/auth/services/auth_error_tracker.dart';

/// Service class for handling authentication operations
/// Provides methods for Google Sign-In, Apple Sign-In, and Firebase Auth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: Platform.isAndroid 
        ? null // Android uses google-services.json
        : '516693747698-6qbfvl44bp1g3bdthvvf795klc4o9ofj.apps.googleusercontent.com', // iOS client ID
  );
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final AuthErrorTracker _errorTracker = AuthErrorTracker.instance;
  bool _isInitialized = false;

  /// Initialize the AuthService
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      Logger.info('Initializing AuthService', category: LogCategory.auth);
      
      // Initialize error tracking service
      await ErrorTrackingService.instance.initialize();
      
      // Wait a bit for Firebase to be fully ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if Firebase is initialized by trying to get current user
      _firebaseAuth.currentUser;
      
      // If user is already signed in, attempt to log in to RevenueCat with the same user id
      try {
        final existingUser = _firebaseAuth.currentUser;
        if (existingUser != null) {
          await Purchases.logIn(existingUser.uid);
          Logger.info('RevenueCat login successful for existing user', category: LogCategory.auth);
          
          // Set user context for error tracking
          ErrorTrackingService.instance.setUserId(existingUser.uid);
        }
      } catch (e) {
        final authError = AuthError.fromPlatformException(e, details: 'RevenueCat initialization');
        _errorTracker.trackError('initialize_revenuecat', authError);
      }

      _isInitialized = true;
      Logger.info('AuthService initialization completed', category: LogCategory.auth);
    } catch (e) {
      final authError = AuthError.unknown(message: 'AuthService initialization failed', originalException: e);
      _errorTracker.trackError('initialize', authError);
      _isInitialized = true; // Mark as initialized even if failed to avoid infinite retries
    }
  }

  /// Get the current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Get stream of auth state changes
  Stream<User?> get authStateChanges {
    if (!_isInitialized) {
      return Stream.value(null);
    }
    
    try {
      return _firebaseAuth.authStateChanges();
    } catch (e) {
      Logger.error('AuthService: Error creating authStateChanges stream', error: e, category: LogCategory.auth);
      return Stream.value(null);
    }
  }

  /// Sign in with Google
  /// Returns the User if successful, null if cancelled or failed
  Future<User?> signInWithGoogle() async {
    const operation = 'google_sign_in';
    _errorTracker.trackAttempt(operation);
    
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        final authError = AuthError.network(
          code: 'no_internet',
          message: 'No internet connection available',
          details: 'Google Sign-In requires internet connection',
        );
        _errorTracker.trackError(operation, authError);
        return null;
      }

      Logger.info('Starting Google Sign-In process', category: LogCategory.auth);
      ErrorTrackingService.instance.recordAuthEvent('google_signin_started');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in flow
        final authError = AuthError.user(
          code: 'sign_in_canceled',
          message: 'User cancelled Google Sign-In',
          userMessage: 'Giriş işlemi iptal edildi',
        );
        _errorTracker.trackError(operation, authError);
        return null;
      }

      Logger.info('Google account selected: ${googleUser.email}', category: LogCategory.auth);

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        final authError = AuthError.platform(
          code: 'missing_tokens',
          message: 'Failed to obtain authentication tokens from Google',
          details: 'accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}',
        );
        _errorTracker.trackError(operation, authError);
        return null;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      Logger.info('Signing in with Firebase using Google credential', category: LogCategory.auth);

      // Sign in the user with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        stopwatch.stop();
        Logger.performance('google_sign_in', stopwatch.elapsed, context: {
          'user_id': user.uid,
          'email': user.email,
        });
        
        _errorTracker.trackSuccess(operation, context: {
          'user_id': user.uid,
          'email': user.email,
          'duration_ms': stopwatch.elapsedMilliseconds,
        });
        
        // Set user context for error tracking
        ErrorTrackingService.instance.setUserId(user.uid);
        
        // Link RevenueCat to the authenticated user
        try {
          await Purchases.logIn(user.uid);
          Logger.info('RevenueCat login successful', category: LogCategory.auth);
        } catch (e) {
          final authError = AuthError.fromPlatformException(e, details: 'RevenueCat login after Google Sign-In');
          _errorTracker.trackError('revenuecat_login', authError);
        }
        
        // Reset user progress for new user (Google Sign-In)
        try {
          final userProgressService = UserProgressService.instance;
          await userProgressService.resetForNewUser();
          // Additional force refresh to ensure UI updates
          await userProgressService.forceRefreshStreams();
          Logger.info('User progress reset and streams refreshed for new user (Google)', category: LogCategory.auth);
        } catch (e) {
          final authError = AuthError.fromPlatformException(e, details: 'Failed to reset user progress for new user');
          _errorTracker.trackError('reset_user_progress', authError);
        }
      }

      return user;
    } on PlatformException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromPlatformException(e, details: 'Google Sign-In platform error');
      _errorTracker.trackError(operation, authError);
      return null;
    } on FirebaseAuthException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromFirebaseAuthException(e, details: 'Google Sign-In Firebase error');
      _errorTracker.trackError(operation, authError);
      return null;
    } catch (e) {
      stopwatch.stop();
      final authError = AuthError.unknown(
        message: 'Unexpected error during Google Sign-In',
        details: e.toString(),
        originalException: e,
      );
      _errorTracker.trackError(operation, authError);
      return null;
    }
  }

  /// Sign in with Apple (iOS only)
  /// Returns the User if successful, null if cancelled or failed
  Future<User?> signInWithApple() async {
    const operation = 'apple_sign_in';
    _errorTracker.trackAttempt(operation);
    
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check if Apple Sign-In is available (iOS 13.0+ or macOS 10.15+)
      if (!Platform.isIOS && !Platform.isMacOS) {
        final authError = AuthError.platform(
          code: 'platform_not_supported',
          message: 'Apple Sign-In is only available on iOS and macOS',
          details: 'Current platform: ${Platform.operatingSystem}',
        );
        _errorTracker.trackError(operation, authError);
        return null;
      }

      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        final authError = AuthError.network(
          code: 'no_internet',
          message: 'No internet connection available',
          details: 'Apple Sign-In requires internet connection',
        );
        _errorTracker.trackError(operation, authError);
        return null;
      }

      // Check if Apple Sign-In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        final authError = AuthError.platform(
          code: 'service_not_available',
          message: 'Apple Sign-In is not available on this device',
          details: 'Device may not support Apple Sign-In or iOS version is too old',
        );
        _errorTracker.trackError(operation, authError);
        return null;
      }

      Logger.info('Starting Apple Sign-In process', category: LogCategory.auth);
      ErrorTrackingService.instance.recordAuthEvent('apple_signin_started');

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        final authError = AuthError.platform(
          code: 'missing_identity_token',
          message: 'Failed to obtain identity token from Apple',
          details: 'Apple Sign-In did not return required identity token',
        );
        _errorTracker.trackError(operation, authError);
        return null;
      }

      Logger.info('Apple credential obtained', category: LogCategory.auth);

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      Logger.info('Signing in with Firebase using Apple credential', category: LogCategory.auth);

      // Sign in the user with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      final user = userCredential.user;
      if (user != null) {
        stopwatch.stop();
        Logger.performance('apple_sign_in', stopwatch.elapsed, context: {
          'user_id': user.uid,
          'email': user.email,
        });
        
        _errorTracker.trackSuccess(operation, context: {
          'user_id': user.uid,
          'email': user.email,
          'duration_ms': stopwatch.elapsedMilliseconds,
        });
        
        // Set user context for error tracking
        ErrorTrackingService.instance.setUserId(user.uid);
        
        // Update display name if it's not set and we have it from Apple
        if (user.displayName == null && appleCredential.givenName != null) {
          try {
            final displayName = '${appleCredential.givenName} ${appleCredential.familyName ?? ''}';
            await user.updateDisplayName(displayName);
            Logger.info('Updated display name: $displayName', category: LogCategory.auth);
          } catch (e) {
            final authError = AuthError.fromFirebaseAuthException(e, details: 'Failed to update display name');
            _errorTracker.trackError('update_display_name', authError);
          }
        }
        
        // Link RevenueCat to the authenticated user
        try {
          await Purchases.logIn(user.uid);
          Logger.info('RevenueCat login successful', category: LogCategory.auth);
        } catch (e) {
          final authError = AuthError.fromPlatformException(e, details: 'RevenueCat login after Apple Sign-In');
          _errorTracker.trackError('revenuecat_login', authError);
        }
        
        // Reset user progress for new user (Apple Sign-In)
        try {
          final userProgressService = UserProgressService.instance;
          await userProgressService.resetForNewUser();
          // Additional force refresh to ensure UI updates
          await userProgressService.forceRefreshStreams();
          Logger.info('User progress reset and streams refreshed for new user (Apple)', category: LogCategory.auth);
        } catch (e) {
          final authError = AuthError.fromPlatformException(e, details: 'Failed to reset user progress for new user');
          _errorTracker.trackError('reset_user_progress', authError);
        }
      }

      return user;
    } on PlatformException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromPlatformException(e, details: 'Apple Sign-In platform error');
      _errorTracker.trackError(operation, authError);
      return null;
    } on FirebaseAuthException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromFirebaseAuthException(e, details: 'Apple Sign-In Firebase error');
      _errorTracker.trackError(operation, authError);
      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      stopwatch.stop();
      final authError = AuthError.platform(
        code: e.code.toString(),
        message: 'Apple Sign-In authorization error: ${e.message}',
        details: 'Authorization error code: ${e.code}',
        originalException: e,
      );
      _errorTracker.trackError(operation, authError);
      return null;
    } catch (e) {
      stopwatch.stop();
      final authError = AuthError.unknown(
        message: 'Unexpected error during Apple Sign-In',
        details: e.toString(),
        originalException: e,
      );
      _errorTracker.trackError(operation, authError);
      return null;
    }
  }

  /// Sign out the current user
  /// Clears both Firebase Auth and Google Sign-In sessions
  Future<void> signOut() async {
    const operation = 'sign_out';
    _errorTracker.trackAttempt(operation);
    
    final stopwatch = Stopwatch()..start();
    
    try {
      Logger.info('Starting sign out process', category: LogCategory.auth);
      ErrorTrackingService.instance.recordAuthEvent('sign_out_started');
      
      // Sign out from Google
      try {
        await _googleSignIn.signOut();
        Logger.info('Google sign out successful', category: LogCategory.auth);
      } catch (e) {
        final authError = AuthError.fromPlatformException(e, details: 'Failed to sign out from Google');
        _errorTracker.trackError('google_sign_out', authError);
      }
      
      // Sign out from Firebase
      try {
        await _firebaseAuth.signOut();
        Logger.info('Firebase sign out successful', category: LogCategory.auth);
      } catch (e) {
        final authError = AuthError.fromFirebaseAuthException(e, details: 'Failed to sign out from Firebase');
        _errorTracker.trackError('firebase_sign_out', authError);
        rethrow; // Re-throw Firebase errors as they're critical
      }

      // Also log out from RevenueCat to clear identified customer
      try {
        await Purchases.logOut();
        Logger.info('RevenueCat logout successful', category: LogCategory.auth);
      } catch (e) {
        final authError = AuthError.fromPlatformException(e, details: 'Failed to logout from RevenueCat');
        _errorTracker.trackError('revenuecat_logout', authError);
      }
      
      // Clear user progress data when signing out
      try {
        final userProgressService = UserProgressService.instance;
        await userProgressService.resetForNewUser();
        Logger.info('User progress data cleared successfully', category: LogCategory.auth);
      } catch (e) {
        final authError = AuthError.fromPlatformException(e, details: 'Failed to clear user progress data');
        _errorTracker.trackError('clear_user_progress', authError);
      }
      
      // Clear user context from error tracking
      ErrorTrackingService.instance.setUserId(null);
      
      stopwatch.stop();
      Logger.performance('sign_out', stopwatch.elapsed);
      
      _errorTracker.trackSuccess(operation, context: {
        'duration_ms': stopwatch.elapsedMilliseconds,
      });
      
      Logger.info('Sign out process completed', category: LogCategory.auth);
    } on FirebaseAuthException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromFirebaseAuthException(e, details: 'Sign out Firebase error');
      _errorTracker.trackError(operation, authError);
      rethrow;
    } on PlatformException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromPlatformException(e, details: 'Sign out platform error');
      _errorTracker.trackError(operation, authError);
      rethrow;
    } catch (e) {
      stopwatch.stop();
      final authError = AuthError.unknown(
        message: 'Unexpected error during sign out',
        details: e.toString(),
        originalException: e,
      );
      _errorTracker.trackError(operation, authError);
      
      // Even if there's an error, we should still try to sign out from Firebase
      try {
        await _firebaseAuth.signOut();
      } catch (fallbackError) {
        final fallbackAuthError = AuthError.fromFirebaseAuthException(fallbackError, details: 'Fallback Firebase sign out');
        _errorTracker.trackError('fallback_firebase_sign_out', fallbackAuthError);
      }
      rethrow;
    }
  }

  /// Delete the current user account
  /// This is a destructive operation that cannot be undone
  Future<bool> deleteAccount() async {
    const operation = 'delete_account';
    _errorTracker.trackAttempt(operation);
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final user = currentUser;
      if (user == null) {
        final authError = AuthError.user(
          code: 'no_user',
          message: 'Delete account called but no user is signed in',
          userMessage: 'Silinecek hesap bulunamadı',
        );
        _errorTracker.trackError(operation, authError);
        return false;
      }

      Logger.info('Starting account deletion process for user: ${user.uid}', category: LogCategory.auth);
      ErrorTrackingService.instance.recordAuthEvent('account_deletion_started', properties: {
        'user_id': user.uid,
        'is_anonymous': user.isAnonymous,
      });

      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        final authError = AuthError.network(
          code: 'no_internet',
          message: 'No internet connection available',
          details: 'Account deletion requires internet connection',
        );
        _errorTracker.trackError(operation, authError);
        return false;
      }

      // Delete the user account
      await user.delete();
      Logger.info('Firebase account deletion successful', category: LogCategory.auth);
      
      // Also sign out from Google if they were signed in with Google
      try {
        await _googleSignIn.signOut();
        Logger.info('Google sign out after deletion successful', category: LogCategory.auth);
      } catch (e) {
        final authError = AuthError.fromPlatformException(e, details: 'Failed to sign out from Google after account deletion');
        _errorTracker.trackError('google_sign_out_after_delete', authError);
      }
      
      // Log out from RevenueCat
      try {
        await Purchases.logOut();
        Logger.info('RevenueCat logout after deletion successful', category: LogCategory.auth);
      } catch (e) {
        final authError = AuthError.fromPlatformException(e, details: 'Failed to logout from RevenueCat after account deletion');
        _errorTracker.trackError('revenuecat_logout_after_delete', authError);
      }
      
      // Clear user context from error tracking
      ErrorTrackingService.instance.setUserId(null);
      
      stopwatch.stop();
      Logger.performance('delete_account', stopwatch.elapsed);
      
      _errorTracker.trackSuccess(operation, context: {
        'duration_ms': stopwatch.elapsedMilliseconds,
      });
      
      Logger.info('Account deletion process completed successfully', category: LogCategory.auth);
      return true;
    } on FirebaseAuthException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromFirebaseAuthException(e, details: 'Account deletion Firebase error');
      _errorTracker.trackError(operation, authError);
      return false;
    } on PlatformException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromPlatformException(e, details: 'Account deletion platform error');
      _errorTracker.trackError(operation, authError);
      return false;
    } catch (e) {
      stopwatch.stop();
      final authError = AuthError.unknown(
        message: 'Unexpected error during account deletion',
        details: e.toString(),
        originalException: e,
      );
      _errorTracker.trackError(operation, authError);
      return false;
    }
  }

  /// Get user display name, with fallback to email
  String? get userDisplayName {
    final user = currentUser;
    if (user == null) return null;
    
    return user.displayName ?? user.email?.split('@').first;
  }

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Get user profile photo URL
  String? get userPhotoURL => currentUser?.photoURL;

  /// Get auth error statistics for monitoring
  Map<String, dynamic> getAuthErrorStats() {
    return _errorTracker.getErrorStats();
  }

  /// Get auth health status
  Map<String, dynamic> getAuthHealthStatus() {
    return _errorTracker.getHealthStatus();
  }

  /// Clear auth error statistics
  void clearAuthErrorStats() {
    _errorTracker.clearStats();
  }

  /// Export auth error data for analysis
  Map<String, dynamic> exportAuthErrorData() {
    return _errorTracker.exportErrorData();
  }



  /// Sign in anonymously as guest
  /// Returns the User if successful, null if failed
  Future<User?> signInAsGuest() async {
    const operation = 'guest_sign_in';
    _errorTracker.trackAttempt(operation);
    
    final stopwatch = Stopwatch()..start();
    
    try {
      Logger.info('Starting anonymous sign-in process', category: LogCategory.auth);
      ErrorTrackingService.instance.recordAuthEvent('guest_signin_started');

      // Sign in anonymously with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInAnonymously();

      final user = userCredential.user;
      if (user != null) {
        stopwatch.stop();
        Logger.performance('guest_sign_in', stopwatch.elapsed, context: {
          'user_id': user.uid,
        });
        
        _errorTracker.trackSuccess(operation, context: {
          'user_id': user.uid,
          'duration_ms': stopwatch.elapsedMilliseconds,
        });
        
        // Set user context for error tracking
        ErrorTrackingService.instance.setUserId(user.uid);
        ErrorTrackingService.instance.setCustomContext('user_type', 'guest');
        
        // Link RevenueCat to the anonymous user
        try {
          await Purchases.logIn(user.uid);
          Logger.info('RevenueCat login successful for guest user', category: LogCategory.auth);
        } catch (e) {
          final authError = AuthError.fromPlatformException(e, details: 'RevenueCat login for guest user');
          _errorTracker.trackError('revenuecat_login_guest', authError);
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      stopwatch.stop();
      final authError = AuthError.fromFirebaseAuthException(e, details: 'Guest sign-in Firebase error');
      _errorTracker.trackError(operation, authError);
      return null;
    } catch (e) {
      stopwatch.stop();
      final authError = AuthError.unknown(
        message: 'Unexpected error during anonymous sign-in',
        details: e.toString(),
        originalException: e,
      );
      _errorTracker.trackError(operation, authError);
      return null;
    }
  }

  /// Link anonymous account with Google credential
  /// This allows guest users to upgrade to a full account
  Future<User?> linkGuestWithGoogle() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        Logger.authError('Link Guest with Google', 'No anonymous user to link');
        return null;
      }

      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        Logger.networkError('Link Guest with Google', 'No internet connection available');
        return null;
      }

      Logger.info('Starting Google Sign-In for account linking');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in flow
        Logger.info('Google Sign-In cancelled by user during linking');
        return null;
      }

      Logger.info('Google account selected for linking: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        Logger.authError('Link Guest with Google', 'Failed to obtain authentication tokens');
        return null;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      Logger.info('Linking anonymous account with Google credential');

      // Link the anonymous account with Google credential
      final UserCredential userCredential = await currentUser.linkWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        Logger.info('Account linking successful: ${user.uid}');
        Logger.info('User is no longer anonymous: ${!user.isAnonymous}');
      }

      return user;
    } on PlatformException catch (e) {
      final authError = AuthError.fromPlatformException(e, details: 'Link Guest with Google platform error');
      _errorTracker.trackError('link_guest_google', authError);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // The credential is already associated with a different user account
        Logger.authError('Link Guest with Google', e, 
            details: 'This Google account is already linked to another user');
        
        // In this case, we should sign out the anonymous user and sign in with the existing account
        try {
          await _firebaseAuth.signOut();
          Logger.info('Signed out anonymous user due to credential conflict');
          
          // Now sign in with the Google account
          final googleUser = await _googleSignIn.signIn();
          if (googleUser != null) {
            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            
            final userCredential = await _firebaseAuth.signInWithCredential(credential);
            Logger.info('Signed in with existing Google account: ${userCredential.user?.uid}');
            return userCredential.user;
          } else {
            Logger.authError('Link Guest with Google Fallback', 'Google user is null');
            return null;
          }
        } catch (fallbackError) {
          Logger.authError('Link Guest with Google Fallback', fallbackError);
          return null;
        }
      } else {
        final authError = AuthError.fromFirebaseAuthException(e, details: 'Link Guest with Google Firebase error');
        _errorTracker.trackError('link_guest_google', authError);
        return null;
      }
    } catch (e) {
      Logger.authError('Link Guest with Google', e, details: 'Unexpected error during account linking');
      return null;
    }
  }

  /// Link anonymous account with Apple credential (iOS only)
  /// This allows guest users to upgrade to a full account
  Future<User?> linkGuestWithApple() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        Logger.authError('Link Guest with Apple', 'No anonymous user to link');
        return null;
      }

      // Check if Apple Sign-In is available (iOS 13.0+ or macOS 10.15+)
      if (!Platform.isIOS && !Platform.isMacOS) {
        Logger.authError('Link Guest with Apple', 'Platform not supported', 
            details: 'Apple Sign-In is only available on iOS and macOS');
        return null;
      }

      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        Logger.networkError('Link Guest with Apple', 'No internet connection available');
        return null;
      }

      // Check if Apple Sign-In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        Logger.authError('Link Guest with Apple', 'Service not available', 
            details: 'Apple Sign-In is not available on this device');
        return null;
      }

      Logger.info('Starting Apple Sign-In for account linking');

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        Logger.authError('Link Guest with Apple', 'Failed to obtain identity token');
        return null;
      }

      Logger.info('Apple credential obtained for linking');

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      Logger.info('Linking anonymous account with Apple credential');

      // Link the anonymous account with Apple credential
      final UserCredential userCredential = await currentUser.linkWithCredential(oauthCredential);
      
      final user = userCredential.user;
      if (user != null) {
        Logger.info('Account linking successful: ${user.uid}');
        Logger.info('User is no longer anonymous: ${!user.isAnonymous}');
        
        // Update display name if it's not set and we have it from Apple
        if (user.displayName == null && appleCredential.givenName != null) {
          try {
            final displayName = '${appleCredential.givenName} ${appleCredential.familyName ?? ''}';
            await user.updateDisplayName(displayName);
            Logger.info('Updated display name: $displayName');
          } catch (e) {
            Logger.authError('Link Guest with Apple Display Name Update', e, 
                details: 'Failed to update display name');
          }
        }
      }

      return user;
    } on PlatformException catch (e) {
      final authError = AuthError.fromPlatformException(e, details: 'Link Guest with Apple platform error');
      _errorTracker.trackError('link_guest_apple', authError);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // The credential is already associated with a different user account
        Logger.authError('Link Guest with Apple', e, 
            details: 'This Apple account is already linked to another user');
        
        // In this case, we should sign out the anonymous user and sign in with the existing account
        try {
          await _firebaseAuth.signOut();
          Logger.info('Signed out anonymous user due to credential conflict');
          
          // Now sign in with the Apple account
          final appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
          );
          
          final oauthCredential = OAuthProvider("apple.com").credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode,
          );
          
          final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
          Logger.info('Signed in with existing Apple account: ${userCredential.user?.uid}');
          return userCredential.user;
        } catch (fallbackError) {
          Logger.authError('Link Guest with Apple Fallback', fallbackError);
          return null;
        }
      } else {
        final authError = AuthError.fromFirebaseAuthException(e, details: 'Link Guest with Apple Firebase error');
        _errorTracker.trackError('link_guest_apple', authError);
        return null;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      Logger.authError('Link Guest with Apple', e, details: 'Authorization error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      Logger.authError('Link Guest with Apple', e, details: 'Unexpected error during account linking');
      return null;
    }
  }

  /// Check if the current user is a guest (anonymous)
  bool get isGuest => currentUser?.isAnonymous ?? false;

  /// Check if the current user is authenticated (not anonymous)
  bool get isAuthenticated => currentUser != null && !isGuest;

  /// Get user-friendly error message for display in UI
  String getUserFriendlyErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          return 'Bu e-posta adresi farklı bir giriş yöntemi ile kayıtlı';
        case 'invalid-credential':
          return 'Geçersiz kimlik bilgileri';
        case 'operation-not-allowed':
          return 'Bu giriş yöntemi şu anda kullanılamıyor';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakılmış';
        case 'network-request-failed':
          return 'İnternet bağlantınızı kontrol edin';
        case 'too-many-requests':
          return 'Çok fazla deneme yapıldı, lütfen daha sonra tekrar deneyin';
        case 'credential-already-in-use':
          return 'Bu hesap zaten başka bir kullanıcı tarafından kullanılıyor';
        default:
          return 'Giriş yapılırken bir hata oluştu';
      }
    } else if (error is PlatformException) {
      switch (error.code) {
        case 'sign_in_canceled':
        case 'sign_in_cancelled':
          return 'Giriş işlemi iptal edildi';
        case 'network_error':
          return 'İnternet bağlantınızı kontrol edin';
        default:
          return 'Giriş yapılırken bir hata oluştu';
      }
    }
    
    return 'Beklenmeyen bir hata oluştu';
  }

  /// Create AuthError from exception
  AuthError createAuthError(Object exception, String operation, {String? details}) {
    if (exception.toString().contains('FirebaseAuthException')) {
      return AuthError.fromFirebaseAuthException(exception, details: details);
    } else if (exception is PlatformException) {
      return AuthError.fromPlatformException(exception, details: details);
    } else {
      return AuthError.unknown(
        message: exception.toString(),
        details: details,
        originalException: exception,
      );
    }
  }

  /// Get current auth state as AuthStateModel
  AuthStateModel get currentAuthState {
    return AuthStateModel.fromUser(_firebaseAuth.currentUser);
  }

  /// Stream of AuthStateModel changes
  Stream<AuthStateModel> get authStateModelChanges {
    return _firebaseAuth.authStateChanges().map((user) => AuthStateModel.fromUser(user));
  }
}