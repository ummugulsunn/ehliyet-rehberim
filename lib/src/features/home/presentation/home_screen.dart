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
import '../../favorites/presentation/favorites_screen.dart';
import 'widgets/smart_review_card.dart';
import 'widgets/readiness_card.dart';
import 'widgets/exam_simulation_card.dart';
import 'widgets/daily_tip_card.dart';
import '../../leaderboard/presentation/leaderboard_screen.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // ... AppBar remains same ...
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
                  return Icon(Icons.account_circle_outlined, color: AppColors.textSecondary);
                } else if (user.photoURL != null && user.photoURL!.isNotEmpty) {
                  return ClipOval(
                    child: Image.network(user.photoURL!, width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.account_circle, color: AppColors.primary)),
                  );
                } else {
                  return Icon(Icons.account_circle, color: AppColors.primary);
                }
              },
              loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => Icon(Icons.account_circle_outlined, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: authState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Hata: $error')),
          data: (user) => ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Dynamic Header
              DynamicHeaderWidget(authState: authState),
              
              const SizedBox(height: 16),
              
              // NEW: Daily Tip Card
              const DailyTipCard(),
              
              const SizedBox(height: 24),
              
              // Primary Action (Karma Test)
              _buildPrimaryActionCard(context),
              
              const SizedBox(height: 32),

              // Status Section
              Text(
                'Hazırlık Durumu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: PageView(
                  controller: PageController(viewportFraction: 0.92),
                  padEnds: false,
                  children: const [
                    Padding(padding: EdgeInsets.only(right: 12), child: ReadinessCard()),
                    Padding(padding: EdgeInsets.only(right: 12), child: SmartReviewCard()),
                    Padding(padding: EdgeInsets.only(right: 12), child: ExamSimulationCard()),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // Tools Section (Redesigned as List)
              Text(
                'Çalışma Araçları',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFeatureList(context, ref),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ... _buildPrimaryActionCard remains same ...
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
                    border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.4), width: 3),
                  ),
                  child: Icon(Icons.play_arrow_rounded, size: 56, color: AppColors.onPrimary),
                ),
                const SizedBox(height: 24),
                Text(
                  'Karma Teste Başla',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.onPrimary,
                    fontSize: 28,
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

  Widget _buildFeatureList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureTile(
                context,
                icon: Icons.topic_outlined,
                title: 'Konu Listesi',
                subtitle: 'Eksiklerini tamamla',
                color: AppColors.info,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TopicSelectionScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureTile(
                context,
                icon: Icons.book,
                title: 'Konu Anlatımı',
                subtitle: 'Ders notları',
                color: AppColors.secondary,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudyGuideListScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
         Row(
          children: [
            Expanded(
              child: _buildFeatureTile(
                context,
                icon: Icons.traffic_outlined,
                title: 'Trafik İşaretleri',
                subtitle: 'Görsel hafıza',
                color: Colors.orange,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrafficSignsScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureTile(
                context,
                icon: Icons.refresh_outlined,
                title: 'Yanlışlarım',
                subtitle: 'Hatalarını çöz',
                color: AppColors.error,
                onTap: () async {
                   // Yanlışlarım logic (Keeping existing logic)
                   final userProgress = ref.read(userProgressRepositoryProvider);
                   final wrongCount = await userProgress.getWrongAnswerIdsCount();
                   
                   if (wrongCount == 0) {
                      if(!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hiç yanlışın yok! Harika gidiyorsun.')));
                      return;
                   }

                   final wrongQuestions = await ref.refresh(wrongQuestionsProvider.future);
                   if(!context.mounted) return;
                   
                   if (wrongQuestions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yüklenecek yanlış soru bulunamadı.')));
                      return;
                   }
                   
                   Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        examId: 'yanliş_sorular',
                        preloadedQuestions: wrongQuestions,
                        category: 'Yanlışlarım',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFeatureTile(
          context,
          icon: Icons.analytics_outlined,
          title: 'İstatistikler & Başarımlar',
          subtitle: 'Gelişimini takip et',
          color: AppColors.success,
          isHorizontal: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatsScreen())),
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureTile(
                context,
                icon: Icons.favorite_rounded,
                title: 'Favorilerim',
                subtitle: 'Kaydettiğin sorular',
                color: Colors.pink,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureTile(
                context,
                icon: Icons.emoji_events_rounded,
                title: 'Liderlik Tablosu',
                subtitle: 'Sıralamanı gör',
                color: Colors.deepPurple,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isHorizontal = false,
  }) {
    return Container(
      height: isHorizontal ? 80 : 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isHorizontal 
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                ],
              ),
          ),
        ),
      ),
    );
  }
}
