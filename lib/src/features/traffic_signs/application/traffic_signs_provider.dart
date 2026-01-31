import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/traffic_sign_model.dart';
import '../../quiz/application/quiz_providers.dart';

enum TrafficSignViewMode { list, grid }

/// State provider for the view mode (List vs Grid)
final trafficSignViewModeProvider = StateProvider<TrafficSignViewMode>(
  (ref) => TrafficSignViewMode.list,
);

/// Future provider that loads traffic sign categories from assets
final trafficSignsProvider = FutureProvider<List<TrafficSignCategory>>((
  ref,
) async {
  final quizService = ref.read(quizRepositoryProvider);
  return quizService.loadTrafficSigns();
});

/// State provider for the current search query text
final trafficSignSearchQueryProvider = StateProvider<String>((ref) => '');

/// State provider for the currently selected category filter
final trafficSignCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Provider that returns filtered traffic sign categories based on search and category filter
final filteredTrafficSignsProvider = FutureProvider<List<TrafficSignCategory>>((
  ref,
) async {
  // Get the original data
  final allCategories = await ref.watch(trafficSignsProvider.future);

  // Get current filter states
  final searchQuery = ref
      .watch(trafficSignSearchQueryProvider)
      .toLowerCase()
      .trim();
  final selectedCategory = ref.watch(trafficSignCategoryFilterProvider);

  // Start with all categories
  List<TrafficSignCategory> filteredCategories = allCategories;

  // Apply category filter first
  if (selectedCategory != null) {
    filteredCategories = allCategories
        .where((category) => category.categoryName == selectedCategory)
        .toList();
  }

  // Apply search filter if there's a search query
  if (searchQuery.isNotEmpty) {
    filteredCategories = filteredCategories
        .map((category) {
          // Filter signs within each category based on search query
          final filteredSigns = category.signs
              .where((sign) => sign.name.toLowerCase().contains(searchQuery))
              .toList();

          // Return a new category with filtered signs, or null if no signs match
          return filteredSigns.isNotEmpty
              ? TrafficSignCategory(
                  categoryName: category.categoryName,
                  signs: filteredSigns,
                )
              : null;
        })
        .where((category) => category != null)
        .cast<TrafficSignCategory>()
        .toList();
  }

  return filteredCategories;
});
