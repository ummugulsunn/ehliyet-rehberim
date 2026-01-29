import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehliyet_rehberim/src/features/study_guides/application/study_guide_providers.dart';
import 'package:ehliyet_rehberim/src/features/study_guides/domain/study_guide_model.dart';
import 'study_guide_detail_screen.dart';

class StudyGuideListScreen extends ConsumerWidget {
  const StudyGuideListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(studyGuidesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Konu Anlatımları',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
      body: guidesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            'Konu anlatımları yüklenemedi: $e',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
        data: (guides) {
          if (guides.isEmpty) {
            return Center(
              child: Text(
                'Henüz içerik yok',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                     ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: guides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final StudyGuide guide = guides[index];
              return Card(
                color: Theme.of(context).colorScheme.surface,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    guide.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                   subtitle: Text(
                    guide.category,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                         ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                   trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudyGuideDetailScreen(guide: guide),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

