import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/utils/logger.dart';

/// Provider for the AuthRepository singleton instance
/// Use this to access authentication methods like signOut(), signInWithGoogle(), etc.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository.instance;
});

/// StreamProvider that watches Firebase authentication state changes
/// This is the single source of truth for user authentication state
/// Returns:
/// - User object when signed in
/// - null when signed out
/// - loading state during authentication operations
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider that returns whether the user is currently signed in
/// This is a convenience provider derived from authStateProvider
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false, // Assume not signed in during loading
    error: (_, __) => false, // Assume not signed in on error
  );
});

/// Provider that returns the current user's display name
/// Returns null if not signed in or no display name available
final userDisplayNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return null;
      return user.displayName ?? user.email?.split('@').first;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider that returns the current user's email
/// Returns null if not signed in
final userEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.email,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider that returns the current user's photo URL
/// Returns null if not signed in or no photo available
final userPhotoURLProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.photoURL,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for handling authentication operations
/// This provider exposes methods for sign in and sign out operations
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

/// Controller class for authentication operations
/// Provides methods with proper error handling and state management
class AuthController {
  final Ref _ref;
  
  AuthController(this._ref);
  
  AuthRepository get _authRepository => _ref.read(authRepositoryProvider);

  /// Sign in with Google
  /// Returns true if successful, false otherwise
  Future<bool> signInWithGoogle() async {
    try {
      final user = await _authRepository.signInWithGoogle();
      return user != null;
    } catch (e) {
      Logger.authError('Google sign-in', e.toString());
      return false;
    }
  }

  /// Sign in with Apple (iOS only)
  /// Returns true if successful, false otherwise
  Future<bool> signInWithApple() async {
    try {
      final user = await _authRepository.signInWithApple();
      return user != null;
    } catch (e) {
      Logger.authError('Apple sign-in', e.toString());
      return false;
    }
  }

  /// Sign out the current user
  /// Returns true if successful, false otherwise
  Future<bool> signOut() async {
    try {
      await _authRepository.signOut();
      return true;
    } catch (e) {
      Logger.authError('Sign out', e.toString());
      return false;
    }
  }

  /// Delete the current user account
  /// Returns true if successful, false otherwise
  Future<bool> deleteAccount() async {
    try {
      return await _authRepository.deleteAccount();
    } catch (e) {
      Logger.authError('Delete account', e.toString());
      return false;
    }
  }
}