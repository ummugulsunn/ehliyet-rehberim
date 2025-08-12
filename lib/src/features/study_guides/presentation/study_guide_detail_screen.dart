import 'package:flutter/material.dart';
import 'package:ehliyet_rehberim/src/core/models/study_guide_model.dart';
import 'package:ehliyet_rehberim/src/core/theme/app_colors.dart';

class StudyGuideDetailScreen extends StatelessWidget {
  final StudyGuide guide;
  const StudyGuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          guide.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guide.content.length,
        itemBuilder: (context, index) {
          final block = guide.content[index];
          if (block is SubheadingBlock) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Text(
                block.text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            );
          } else if (block is ParagraphBlock) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                block.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
              ),
            );
          } else if (block is ImageBlock) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  block.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Görsel bulunamadı',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (block is KeyInfoBlock) {
            return Card(
              color: AppColors.info.withValues(alpha: 0.08),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        block.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

