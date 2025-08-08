import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../quiz/application/quiz_providers.dart';
import '../../paywall/presentation/paywall_screen.dart';
import '../../topics/presentation/topic_selection_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../auth/application/auth_providers.dart';
import '../presentation/widgets/dynamic_header_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../exams/presentation/exam_selection_screen.dart';
import '../../stats/presentation/stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Ana Sayfa',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
              
              const SizedBox(height: 32),
              
              // Secondary Action Grid
              _buildSecondaryActionGrid(context, ref),
              
              const SizedBox(height: 32),
              
              // Pro Upgrade Banner
              _buildProUpgradeBanner(context),
              
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
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onPrimary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 48,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Karma Teste Başla',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tüm konulardan rastgele bir test çöz',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
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
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.0,
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
          icon: Icons.refresh_outlined,
          title: 'Yanlışlarım\nTesti',
          color: AppColors.warning,
          isPro: true,
          onTap: () async {
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

            // Pro user: load wrong questions
            // Show loading dialog while waiting
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              // Debug: Check current wrong answer count
              final userProgress = ref.read(userProgressServiceProvider);
              final wrongCount = await userProgress.getWrongAnswerIdsCount();
              
              // If too many wrong answers (indicating a bug), clear them
              if (wrongCount > 50) {
                await userProgress.clearAllWrongAnswerIds();
                // ignore: use_build_context_synchronously
                Navigator.of(context, rootNavigator: true).pop();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yanlış sorular listesi temizlendi. Lütfen yeni yanlışlar yapın.')),
                );
                return;
              }
              
              // Always refresh to avoid serving cached empty data
              final wrongQuestions = await ref.refresh(wrongQuestionsProvider.future);

              // ignore: use_build_context_synchronously
              Navigator.of(context, rootNavigator: true).pop();

              if (wrongQuestions.isEmpty) {
                // ignore: use_build_context_synchronously
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
              // ignore: use_build_context_synchronously
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
              // ignore: use_build_context_synchronously
              Navigator.of(context, rootNavigator: true).pop();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sorular yüklenemedi. Lütfen tekrar deneyin.')),
              );
            }
          },
        ),
        if (kDebugMode)
          _buildFeatureCard(
            context,
            icon: Icons.clear_all,
            title: 'Yanlışları\nTemizle',
            color: AppColors.error,
            onTap: () async {
              // Debug: Clear all wrong answers
              final userProgress = ref.read(userProgressServiceProvider);
              await userProgress.clearAllWrongAnswerPairs();
              await userProgress.clearAllWrongAnswerIds();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm yanlış sorular temizlendi!')),
                );
              }
            },
          )
        else
        _buildFeatureCard(
          context,
          icon: Icons.traffic_outlined,
          title: 'Trafik\nİşaretleri',
          color: AppColors.secondary,
          onTap: () {
            // TODO: Navigate to traffic signs screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trafik işaretleri yakında!')),
            );
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (isPro)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.premium, AppColors.premiumDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.premiumShadow,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'PRO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onPremium,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProUpgradeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.premiumDark, AppColors.premium],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PaywallScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.onPremium.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.onPremium.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.onPremium,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pro\'ya Geçerek Tüm Özellikleri Açın',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPremium,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sınırsız soru, özel testler ve daha fazlası',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onPremium.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.onPremium.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.onPremium,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
