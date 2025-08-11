import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/traffic_sign_model.dart';
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
        data: (categories) => _buildContent(context, categories),
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

  Widget _buildContent(BuildContext context, List<TrafficSignCategory> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ExpansionTile(
          title: Text(category.categoryName),
          children: [
            for (final sign in category.signs)
              ListTile(
                leading: Image.asset(
                  sign.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
                title: Text(sign.name),
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


