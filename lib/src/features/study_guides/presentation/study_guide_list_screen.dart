import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehliyet_rehberim/src/features/study_guides/application/study_guide_providers.dart';
import 'package:ehliyet_rehberim/src/core/models/study_guide_model.dart';
import 'package:ehliyet_rehberim/src/core/theme/app_colors.dart';
import 'study_guide_detail_screen.dart';

class StudyGuideListScreen extends ConsumerWidget {
  const StudyGuideListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(studyGuidesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Konu Anlatımları',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ),
      body: guidesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            'Konu anlatımları yüklenemedi: $e',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.error),
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
                    ?.copyWith(color: AppColors.textSecondary),
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
                color: AppColors.surface,
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
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
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

