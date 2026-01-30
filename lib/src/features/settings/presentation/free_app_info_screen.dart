import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:in_app_review/in_app_review.dart';
import 'dart:io';

class FreeAppInfoScreen extends StatelessWidget {
  const FreeAppInfoScreen({super.key});

  Future<void> _rateApp(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;
    
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      // Fallback logic
      try {
        if (Platform.isAndroid) {
          await inAppReview.openStoreListing(appStoreId: 'com.ehliyetrehberim.app');
        } else if (Platform.isIOS) {
          await inAppReview.openStoreListing(appStoreId: '6739002862');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mağaza sayfası açılamadı')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neden Ücretsiz?'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Eğitimde Fırsat Eşitliği',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Ehliyet Rehberim, sürücü adaylarının ehliyet sınavına en iyi şekilde hazırlanabilmesi için geliştirilmiştir. İnanıyoruz ki nitelikli eğitime ve hazırlık materyallerine erişim herkes için ücretsiz olmalıdır.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Bu yüzden uygulamamızda reklam yok, gizli ücretler yok, premium kilitler yok. Her şey tamamen ücretsiz.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Bize Destek Olun',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bu projenin devamlılığını sağlamak ve daha fazla kişiye ulaşmamıza yardımcı olmak isterseniz, bizi Play Store / App Store\'da puanlayabilirsiniz.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _rateApp(context),
                        icon: const Icon(Icons.star_rate_rounded),
                        label: const Text('Bizi Değerlendir'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
