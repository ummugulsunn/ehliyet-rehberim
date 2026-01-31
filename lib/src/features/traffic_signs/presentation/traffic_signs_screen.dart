import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/traffic_sign_model.dart';
import '../../../core/theme/app_colors.dart';

import '../application/traffic_signs_provider.dart';

class TrafficSignsScreen extends ConsumerWidget {
  const TrafficSignsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(trafficSignsProvider);
    final viewMode = ref.watch(trafficSignViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trafik İşaretleri'),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == TrafficSignViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            tooltip: viewMode == TrafficSignViewMode.list
                ? 'Izgara Görünümü'
                : 'Liste Görünümü',
            onPressed: () {
              ref
                  .read(trafficSignViewModeProvider.notifier)
                  .state = viewMode == TrafficSignViewMode.list
                  ? TrafficSignViewMode.grid
                  : TrafficSignViewMode.list;
            },
          ),
        ],
      ),
      body: asyncCategories.when(
        data: (categories) => _buildContent(context, ref, categories),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Trafik işaretleri yüklenemedi: $e'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<TrafficSignCategory> categories,
  ) {
    // Get all unique category names for filter chips
    final categoryNames = categories.map((cat) => cat.categoryName).toList();

    return Column(
      children: [
        // Search Bar
        _buildSearchBar(context, ref),

        // Filter Chips
        _buildFilterChips(context, ref, categoryNames),

        // Content List
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final filteredCategories = ref.watch(
                filteredTrafficSignsProvider,
              );
              return filteredCategories.when(
                data: (filteredCats) =>
                    _buildCategoriesList(context, ref, filteredCats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Hata: $e')),
              );
            },
          ),
        ),
      ],
    );
  }

  // ... _buildSearchBar and _buildFilterChips remain same ...

  Widget _buildCategoriesList(
    BuildContext context,
    WidgetRef ref,
    List<TrafficSignCategory> categories,
  ) {
    final viewMode = ref.watch(trafficSignViewModeProvider);

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Aradığınız kriterlere uygun işaret bulunamadı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return ExpansionTile(
          initiallyExpanded: true, // Auto expand for better UX
          title: Text(
            category.categoryName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Icon(Icons.traffic, color: AppColors.primary),
          children: [
            if (viewMode == TrafficSignViewMode.list)
              ...category.signs.map(
                (sign) => ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        sign.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    sign.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    sign.description.length > 50
                        ? '${sign.description.substring(0, 50)}...'
                        : sign.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrafficSignDetailScreen(sign: sign),
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: category.signs.length,
                itemBuilder: (context, signIndex) {
                  final sign = category.signs[signIndex];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrafficSignDetailScreen(sign: sign),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                sign.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  sign.name,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) =>
            ref.read(trafficSignSearchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Trafik işareti ara...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    List<String> categories,
  ) {
    final selectedCategory = ref.watch(trafficSignCategoryFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Tümü'),
              selected: selectedCategory == null,
              onSelected: (selected) {
                ref.read(trafficSignCategoryFilterProvider.notifier).state =
                    null;
              },
            ),
          ),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  ref.read(trafficSignCategoryFilterProvider.notifier).state =
                      selected ? category : null;
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class TrafficSignDetailScreen extends StatelessWidget {
  final TrafficSign sign;
  const TrafficSignDetailScreen({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(sign.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                sign.imageUrl,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 64),
              ),
            ),
            const SizedBox(height: 16),
            Text(sign.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              sign.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
