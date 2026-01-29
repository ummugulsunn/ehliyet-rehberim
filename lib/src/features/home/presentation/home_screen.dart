import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../quiz/application/quiz_providers.dart';

import '../../quiz/presentation/topic_selection_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../auth/application/auth_providers.dart';
import '../presentation/widgets/dynamic_header_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../quiz/presentation/exam_selection_screen.dart';
import '../../stats/presentation/stats_screen.dart';
import '../../traffic_signs/presentation/traffic_signs_screen.dart';
import '../../study_guides/presentation/study_guide_list_screen.dart';
import 'widgets/achievements_widget.dart';
import 'widgets/smart_review_card.dart';
import 'widgets/readiness_card.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Ana Sayfa',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: authState.when(
              data: (user) {
                if (user == null) {
                  // Misafir kullanıcı - default icon
                  return Icon(
                    Icons.account_circle_outlined,
                    color: AppColors.textSecondary,
                  );
                } else {
                  // Giriş yapmış kullanıcı - profil resmi veya default icon
                  if (user.photoURL != null && user.photoURL!.isNotEmpty) {
                    // Kullanıcının profil resmi varsa
                    return ClipOval(
                      child: Image.network(
                        user.photoURL!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 24,
                            height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                              color: AppColors.surfaceContainerHighest,
                        ),
                        child: Icon(
                              Icons.account_circle,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    // Profil resmi yoksa default icon
                    return Icon(
                      Icons.account_circle,
                      color: AppColors.primary,
                    );
                  }
                }
              },
              loading: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              error: (_, __) => Icon(
                Icons.account_circle_outlined,
                color: AppColors.textSecondary,
              ),
            ),
                      ),
                    ],
                  ),
      body: SafeArea(
        child: authState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                  'Bir hata oluştu',
                  style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          data: (user) => ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              const SizedBox(height: 8),
              
              // Dynamic Header Section
              DynamicHeaderWidget(authState: authState),
              
              
              const SizedBox(height: 32),
              
              // Primary Action Card - Karma Test
              _buildPrimaryActionCard(context),
              
              const SizedBox(height: 24),

              // Smart Review Card (Adaptive Learning)
              const SmartReviewCard(),
              
              const SizedBox(height: 16),
              
              // Exam Readiness Prediction
              const ReadinessCard(),

              const SizedBox(height: 32),
              
              // Secondary Action Grid
              _buildSecondaryActionGrid(context, ref),
              
              const SizedBox(height: 32),
              

              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionCard(BuildContext context) {
    return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
          stops: const [0.0, 0.7, 1.0],
                          ),
        borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
            color: AppColors.primaryShadow.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 60,
            offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                builder: (context) => const ExamSelectionScreen(),
                                ),
                              );
                            },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
                                children: [
                                  Container(
                  padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onPrimary.withValues(alpha: 0.4),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onPrimary.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 56,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                                        Text(
                  'Karma Teste Başla',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.onPrimary,
                    fontSize: 28,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.onPrimary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Tüm konulardan rastgele bir test çöz',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
    );
  }

  Widget _buildSecondaryActionGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.65, // Aggressively reduced to prevent overflow
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.topic_outlined,
          title: 'Konu Konu\nÇalış',
          color: AppColors.info,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const TopicSelectionScreen(),
                                ),
                              );
                            },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.analytics_outlined,
          title: 'İstatistiklerim',
          color: AppColors.success,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StatsScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.emoji_events_outlined,
          title: 'Başarımlar',
          color: Colors.orange,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: const AchievementsWidget(),
                ),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.refresh_outlined,
          title: 'Yanlışlarım\nTesti',
          color: AppColors.warning,
          // isPro: true, // Removed for free version
          onTap: () async {
            // Locked feature check removed - always allow access
            /*
            final proStatusAsync = ref.read(proStatusProvider);
            final isPro = proStatusAsync.when(data: (v) => v, loading: () => false, error: (_, __) => false);

            if (!isPro) {
              // Navigate to paywall
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
              return;
            }
            */

            // Pro user: load wrong questions
            // Show loading dialog while waiting
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              // Debug: Check current wrong answer count
              final userProgress = ref.read(userProgressRepositoryProvider);
              final wrongCount = await userProgress.getWrongAnswerIdsCount();
              
              // If too many wrong answers (indicating a bug), clear them
              if (wrongCount > 50) {
                await userProgress.clearAllWrongAnswerIds();
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true).pop();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yanlış sorular listesi temizlendi. Lütfen yeni yanlışlar yapın.')),
                );
                return;
              }
              
              // Always refresh to avoid serving cached empty data
              final wrongQuestions = await ref.refresh(wrongQuestionsProvider.future);

              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true).pop();

              if (wrongQuestions.isEmpty) {
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Harika!'),
                    content: const Text('Tekrar etmen gereken bir yanlışın bulunmuyor.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
                return;
              }

              // Navigate to QuizScreen with preloaded wrong questions
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    examId: 'yanliş_sorular', // Unique exam ID for wrong questions
                    preloadedQuestions: wrongQuestions,
                    category: 'Yanlışlarım',
                  ),
                ),
              );
            } catch (_) {
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true).pop();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sorular yüklenemedi. Lütfen tekrar deneyin.')),
              );
            }
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.traffic_outlined,
          title: 'Trafik\nİşaretleri',
          color: AppColors.secondary,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TrafficSignsScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.book,
          title: 'Konu\nAnlatımları',
          color: AppColors.info,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                builder: (_) => const StudyGuideListScreen(),
                        ),
                      );
                    },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.cleaning_services_outlined,
          title: 'Yanlışları\nTemizle',
          color: AppColors.error,
          onTap: () async {
            // Show confirmation dialog
            final shouldClear = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Yanlışları Temizle'),
                content: const Text(
                  'Tüm yanlış cevap geçmişiniz silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            );

            if (shouldClear == true) {
              try {
                final userProgress = ref.read(userProgressRepositoryProvider);
                
                // Get count before clearing for debug
                final beforeCount = await userProgress.getWrongAnswerIdsCount();
                
                // Clear both old and new wrong answer systems
                await userProgress.clearAllWrongAnswerIds();
                await userProgress.clearAllWrongAnswerPairs();
                
                // Get count after clearing for debug
                final afterCount = await userProgress.getWrongAnswerIdsCount();
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Yanlış cevap geçmişiniz temizlendi. (Önceki: $beforeCount, Sonraki: $afterCount)'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hata oluştu. Lütfen tekrar deneyin.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isPro = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.15),
                            color.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                                height: 1.1,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
