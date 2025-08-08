import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utils/logger.dart';

/// Service class for handling authentication operations
/// Provides methods for Google Sign-In, Apple Sign-In, and Firebase Auth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isInitialized = false;

  /// Initialize the AuthService
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Wait a bit for Firebase to be fully ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if Firebase is initialized by trying to get current user
      _firebaseAuth.currentUser;
      
      _isInitialized = true;
    } catch (e) {
      Logger.error('AuthService: Failed to initialize', e);
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
      Logger.error('AuthService: Error creating authStateChanges stream', e);
      return Stream.value(null);
    }
  }

  /// Sign in with Google
  /// Returns the User if successful, null if cancelled or failed
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in the user with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      return userCredential.user;
    } catch (e) {
      // Log error in development
      if (e is FirebaseAuthException) {
        Logger.authError('Google Sign-In', '${e.code} - ${e.message}');
      } else {
        Logger.authError('Google Sign-In', e.toString());
      }
      return null;
    }
  }

  /// Sign in with Apple (iOS only)
  /// Returns the User if successful, null if cancelled or failed
  Future<User?> signInWithApple() async {
    try {
      // Check if Apple Sign-In is available (iOS 13.0+ or macOS 10.15+)
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw UnsupportedError('Apple Sign-In is only available on iOS and macOS');
      }

      // Check if Apple Sign-In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw UnsupportedError('Apple Sign-In is not available on this device');
      }

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      // Update display name if it's not set and we have it from Apple
      final user = userCredential.user;
      if (user != null && user.displayName == null && appleCredential.givenName != null) {
        await user.updateDisplayName('${appleCredential.givenName} ${appleCredential.familyName ?? ''}');
      }
      
      return user;
    } catch (e) {
      // Log error in development
      if (e is FirebaseAuthException) {
        Logger.authError('Apple Sign-In', '${e.code} - ${e.message}');
      } else if (e is SignInWithAppleAuthorizationException) {
        Logger.authError('Apple Sign-In', '${e.code} - ${e.message}');
      } else {
        Logger.authError('Apple Sign-In', e.toString());
      }
      return null;
    }
  }

  /// Sign out the current user
  /// Clears both Firebase Auth and Google Sign-In sessions
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      Logger.authError('Sign out', e.toString());
      // Even if there's an error, we should still try to sign out from Firebase
      await _firebaseAuth.signOut();
    }
  }

  /// Delete the current user account
  /// This is a destructive operation that cannot be undone
  Future<bool> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // Delete the user account
      await user.delete();
      
      // Also sign out from Google if they were signed in with Google
      await _googleSignIn.signOut();
      
      return true;
    } catch (e) {
      Logger.authError('Delete account', e.toString());
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
}