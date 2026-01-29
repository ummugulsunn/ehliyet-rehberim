import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:flutter/services.dart';
import '../utils/logger.dart';
import 'connectivity_service.dart';
import 'user_progress_service.dart';

/// Service class for handling authentication operations
/// Provides methods for Google Sign-In, Apple Sign-In, and Firebase Auth
class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  static AuthRepository get instance => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: Platform.isAndroid 
        ? null // Android uses google-services.json
        : '516693747698-6qbfvl44bp1g3bdthvvf795klc4o9ofj.apps.googleusercontent.com', // iOS client ID
  );
  final ConnectivityService _connectivityService = ConnectivityService.instance;

  bool _isInitialized = false;

  /// Initialize the AuthService
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      Logger.info('Initializing AuthService');
      
      // Wait a bit for Firebase to be fully ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if Firebase is initialized by trying to get current user
      _firebaseAuth.currentUser;
      
      Logger.info('AuthService initialization completed');
    } catch (e) {
      Logger.error('AuthService initialization failed: $e');
      _isInitialized = true;
    }
  }

  /// Get the current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Get stream of auth state changes
  Stream<User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (e) {
      Logger.error('AuthService: Error creating authStateChanges stream', e);
      return Stream.value(null);
    }
  }

  /// Sign in with Google
  /// Returns the User if successful, null if cancelled or failed
  Future<User?> signInWithGoogle() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        Logger.error('No internet connection available');
        return null;
      }

      Logger.info('Starting Google Sign-In process');

      // Force clear previous session to ensure account picker appears
      try {
        // specific timeout for this cleanup step
        await _googleSignIn.signOut().timeout(const Duration(seconds: 2));
      } catch (e) {
        Logger.info('Pre-signout failed (non-fatal): $e');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in flow
        Logger.info('User cancelled Google Sign-In');
        return null;
      }

      Logger.info('Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        Logger.error('Failed to obtain authentication tokens from Google');
        return null;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      Logger.info('Signing in with Firebase using Google credential');

      // Sign in the user with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        stopwatch.stop();
        Logger.info('Google sign in successful: ${user.uid}');
        

      }

      return user;
    } catch (e) {
      stopwatch.stop();
      Logger.error('Google Sign-In failed: $e');
      return null;
    }
  }

  /// Sign in with Apple (iOS only)
  /// Returns the User if successful, null if cancelled or failed
  Future<User?> signInWithApple() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check if Apple Sign-In is available (iOS 13.0+ or macOS 10.15+)
      if (!Platform.isIOS && !Platform.isMacOS) {
        Logger.error('Apple Sign-In is only available on iOS and macOS');
        return null;
      }

      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        Logger.error('No internet connection available');
        return null;
      }

      // Check if Apple Sign-In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        Logger.error('Apple Sign-In is not available on this device');
        return null;
      }

      Logger.info('Starting Apple Sign-In process');

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        Logger.error('Failed to obtain identity token from Apple');
        return null;
      }

      Logger.info('Apple credential obtained');

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      Logger.info('Signing in with Firebase using Apple credential');

      // Sign in the user with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      final user = userCredential.user;
      if (user != null) {
        stopwatch.stop();
        Logger.info('Apple sign in successful: ${user.uid}');
        
        // Update display name if it's not set and we have it from Apple
        if (user.displayName == null && appleCredential.givenName != null) {
          try {
            final displayName = '${appleCredential.givenName} ${appleCredential.familyName ?? ''}';
            await user.updateDisplayName(displayName);
            Logger.info('Updated display name: $displayName');
          } catch (e) {
            Logger.error('Failed to update display name: $e');
          }
        }
        

      }

      return user;
    } catch (e) {
      stopwatch.stop();
      Logger.error('Apple Sign-In failed: $e');
      return null;
    }
  }

  /// Sign out the current user
  /// Clears both Firebase Auth and Google Sign-In sessions
  Future<void> signOut() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      Logger.info('Starting sign out process');
      
      // Sign out from Google
      try {
        // Check if signed in with a short timeout
        final isSignedIn = await _googleSignIn.isSignedIn().timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
        
        if (isSignedIn) {
          await _googleSignIn.disconnect().timeout(
            const Duration(seconds: 2), 
            onTimeout: () => null,
          );
        }
        await _googleSignIn.signOut().timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );
        Logger.info('Google sign out successful');
      } catch (e) {
        Logger.error('Failed to sign out from Google: $e');
        // Continue to Firebase sign out even if Google fails
      }
      
      // Sign out from Firebase
      try {
        await _firebaseAuth.signOut();
        Logger.info('Firebase sign out successful');
      } catch (e) {
        Logger.error('Failed to sign out from Firebase: $e');
        rethrow; // Re-throw Firebase errors as they're critical
      }
      

      
      stopwatch.stop();
      // Logger.performance('sign_out', stopwatch.elapsed);
      
      Logger.info('Sign out process completed');
    } catch (e) {
      stopwatch.stop();
      Logger.error('Unexpected error during sign out: $e');
      rethrow;
    }
  }

  /// Delete the current user account
  /// This is a destructive operation that cannot be undone
  Future<bool> deleteAccount() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final user = currentUser;
      if (user == null) {
        Logger.error('Delete account called but no user is signed in');
        return false;
      }

      Logger.info('Starting account deletion process for user: ${user.uid}');

      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        Logger.error('No internet connection available');
        return false;
      }

      // Delete the user account
      await user.delete();
      Logger.info('Firebase account deletion successful');
      
      // Also sign out from Google if they were signed in with Google
      try {
        await _googleSignIn.signOut();
        Logger.info('Google sign out after deletion successful');
      } catch (e) {
        Logger.error('Failed to sign out from Google after account deletion: $e');
      }
      
      stopwatch.stop();
      // Logger.performance('delete_account', stopwatch.elapsed);
      
      Logger.info('Account deletion process completed successfully');
      return true;
    } catch (e) {
      stopwatch.stop();
      Logger.error('Unexpected error during account deletion: $e');
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

  /// Sign in anonymously as guest
  /// Returns the User if successful, null if failed
  Future<User?> signInAsGuest() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      Logger.info('Starting anonymous sign-in process');

      // Sign in anonymously with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInAnonymously();

      final user = userCredential.user;
      if (user != null) {
        stopwatch.stop();
        Logger.info('Guest sign in successful: ${user.uid}');
      }

      return user;
    } catch (e) {
      stopwatch.stop();
      Logger.error('Unexpected error during anonymous sign-in: $e');
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
        Logger.error('Link Guest with Google: No internet connection available');
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // The credential is already associated with a different user account
        Logger.authError('Link Guest with Google', e);
        
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
        Logger.authError('Link Guest with Google', 'Firebase error: ${e.message}');
        return null;
      }
    } catch (e) {
      Logger.authError('Link Guest with Google', e);
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
        Logger.authError('Link Guest with Apple', 'Platform not supported (Apple Sign-In is only available on iOS and macOS)');
        return null;
      }

      // Check internet connectivity first
      if (!await _connectivityService.hasInternetConnection()) {
        Logger.error('Link Guest with Apple: No internet connection available');
        return null;
      }

      // Check if Apple Sign-In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        Logger.authError('Link Guest with Apple', 'Service not available (Apple Sign-In not available on device)');
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
            Logger.authError('Link Guest with Apple Display Name Update', e);
          }
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // The credential is already associated with a different user account
        Logger.authError('Link Guest with Apple', e);
        
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
        Logger.authError('Link Guest with Apple', 'Firebase error: ${e.message}');
        return null;
      }
    } catch (e) {
      Logger.authError('Link Guest with Apple', e);
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
          return 'Bir hata oluştu: ${error.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu';
  }
}