import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger.dart';
import '../domain/favorite_item_model.dart';
import 'dart:async';

/// Repository for managing favorite questions and notes
class FavoritesRepository {
  static const String _favoritesKey = 'favorite_questions';

  // Singleton instance
  static final FavoritesRepository instance = FavoritesRepository._();

  FavoritesRepository._();

  // Stream controller for real-time updates
  final _favoritesController = StreamController<List<FavoriteItem>>.broadcast();
  Stream<List<FavoriteItem>> get favoritesStream => _favoritesController.stream;

  List<FavoriteItem> _cachedFavorites = [];
  bool _isInitialized = false;

  /// Initialize the repository
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoritesKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _cachedFavorites = jsonList
            .map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _favoritesController.add(_cachedFavorites);
      _isInitialized = true;
      Logger.info(
        'FavoritesRepository initialized with ${_cachedFavorites.length} items',
      );
    } catch (e) {
      Logger.error('Failed to initialize FavoritesRepository', e);
      _cachedFavorites = [];
      _favoritesController.add([]);
    }
  }

  /// Get current favorites list
  List<FavoriteItem> getFavorites() {
    return List.unmodifiable(_cachedFavorites);
  }

  /// Check if a question is favorited
  bool isFavorite(int questionId) {
    return _cachedFavorites.any((item) => item.questionId == questionId);
  }

  /// Get note for a question
  String? getNote(int questionId) {
    try {
      final item = _cachedFavorites.firstWhere(
        (item) => item.questionId == questionId,
      );
      return item.note;
    } catch (_) {
      return null;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(int questionId) async {
    final existingIndex = _cachedFavorites.indexWhere(
      (item) => item.questionId == questionId,
    );

    if (existingIndex >= 0) {
      // Remove from favorites
      _cachedFavorites.removeAt(existingIndex);
    } else {
      // Add to favorites
      _cachedFavorites.add(
        FavoriteItem(questionId: questionId, savedAt: DateTime.now()),
      );
    }

    await _persistChanges();
  }

  /// Save or update note for a question (adds to favorites if not already there)
  Future<void> saveNote(int questionId, String note) async {
    final existingIndex = _cachedFavorites.indexWhere(
      (item) => item.questionId == questionId,
    );

    if (existingIndex >= 0) {
      // Update existing item
      _cachedFavorites[existingIndex] = _cachedFavorites[existingIndex]
          .copyWith(
            note: note,
            savedAt: DateTime.now(), // Update timestamp on edit
          );
    } else {
      // Add new item with note
      _cachedFavorites.add(
        FavoriteItem(
          questionId: questionId,
          note: note,
          savedAt: DateTime.now(),
        ),
      );
    }

    await _persistChanges();
  }

  /// Persist changes to SharedPreferences and emit update
  Future<void> _persistChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        _cachedFavorites.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, jsonString);

      _favoritesController.add(_cachedFavorites);
    } catch (e) {
      Logger.error('Failed to persist favorites', e);
    }
  }
}
