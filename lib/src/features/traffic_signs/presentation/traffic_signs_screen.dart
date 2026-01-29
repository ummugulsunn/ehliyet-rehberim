import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/traffic_sign_model.dart';
import '../../../core/theme/app_colors.dart';

import '../application/traffic_signs_provider.dart';

class TrafficSignsScreen extends ConsumerWidget {
  const TrafficSignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(trafficSignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trafik İşaretleri'),
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

  Widget _buildContent(BuildContext context, WidgetRef ref, List<TrafficSignCategory> categories) {
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
              final filteredCategories = ref.watch(filteredTrafficSignsProvider);
              return filteredCategories.when(
                data: (filteredCats) => _buildCategoriesList(context, filteredCats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Hata: $e')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            ref.read(trafficSignSearchQueryProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: 'İşaret ara...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, List<String> categoryNames) {
    final selectedCategory = ref.watch(trafficSignCategoryFilterProvider);
    
    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // "All Signs" chip
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: const Text('Tüm İşaretler'),
                selected: selectedCategory == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(trafficSignCategoryFilterProvider.notifier).state = null;
                  }
                },
                selectedColor: AppColors.primaryContainer,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selectedCategory == null ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Category filter chips
            ...categoryNames.map((categoryName) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(categoryName),
                selected: selectedCategory == categoryName,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(trafficSignCategoryFilterProvider.notifier).state = categoryName;
                  }
                },
                selectedColor: AppColors.primaryContainer,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selectedCategory == categoryName ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: selectedCategory == categoryName ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, List<TrafficSignCategory> categories) {
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
          title: Text(
            category.categoryName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Icon(
            Icons.traffic,
            color: AppColors.primary,
          ),
          children: [
            for (final sign in category.signs)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      sign.imageUrl,
                  width: 40,
                  height: 40,
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
              )
          ],
        );
      },
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
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 64),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              sign.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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


