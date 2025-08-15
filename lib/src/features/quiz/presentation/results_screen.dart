import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/quiz_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/widgets/banner_ad_widget.dart' as widgets;

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    
    // Calculate statistics
    final totalQuestions = quizState.totalQuestions;
    final correctAnswers = quizState.score;
    final incorrectAnswers = totalQuestions - correctAnswers;
    final successPercentage = totalQuestions > 0 
        ? (correctAnswers / totalQuestions * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonuçları'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Congratulatory message
            const SizedBox(height: 32),
            Icon(
              Icons.celebration,
              size: 80,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Test Tamamlandı!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Circular progress indicator with score
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: successPercentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(successPercentage),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$correctAnswers/$totalQuestions',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(successPercentage),
                        ),
                      ),
                      Text(
                        '%$successPercentage',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Results summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildResultRow(
                    context,
                    'Doğru Sayısı',
                    correctAnswers.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  _buildResultRow(
                    context,
                    'Yanlış Sayısı',
                    incorrectAnswers.toString(),
                    Icons.cancel,
                    AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  _buildResultRow(
                    context,
                    'Başarı Yüzdesi',
                    '%$successPercentage',
                    Icons.percent,
                    _getScoreColor(successPercentage),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Reset quiz state and navigate back to quiz screen
                      ref.read(quizControllerProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Yeniden Başla',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Bonus points with rewarded ad (if not Pro and score < 80%)
                if (successPercentage < 80) ...[
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.1),
                            AppColors.secondaryLight.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Show rewarded ad for bonus points
                          await AdService.instance.showRewardedAd(
                            onRewardEarned: (reward) {
                              // Give bonus points - improve score by 10%
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 Bonus puan kazandınız! +${reward.amount} puan'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            onAdDismissed: () {
                              // Ad dismissed
                            },
                            onAdFailedToShow: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Reklam şu anda mevcut değil'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.card_giftcard,
                          color: AppColors.secondary,
                        ),
                        label: Text(
                          'Reklam İzleyerek Bonus Puan Kazan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      // Reset quiz state before navigating back to prevent data loss
                      ref.read(quizControllerProvider.notifier).reset();
                      
                      // Mark completion and maybe show an interstitial for non-Pro users
                      await AdService.markQuizCompleted();
                      final isPro = ref.read(proStatusProvider).maybeWhen(
                            data: (v) => v,
                            orElse: () => false,
                          );
                      if (!isPro) {
                        await AdService.showInterstitialIfEligible();
                      }
                      // Navigate back to home screen
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ana Menüye Dön',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const widgets.BannerAdWidget(),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) {
      return AppColors.success;
    } else if (percentage >= 60) {
      return AppColors.secondary;
    } else {
      return AppColors.error;
    }
  }
} 