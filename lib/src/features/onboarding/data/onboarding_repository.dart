import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingRepository {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  final SharedPreferences _sharedPreferences;

  OnboardingRepository(this._sharedPreferences);

  bool get isOnboardingComplete {
    return _sharedPreferences.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _sharedPreferences.setBool(_onboardingCompleteKey, true);
  }
}

// Provider needs SharedPreferences to be initialized first.
// We will override this in main.dart
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  throw UnimplementedError('sharedPreferences must be overridden in main.dart');
});
