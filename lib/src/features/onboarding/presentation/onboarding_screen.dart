import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_gate.dart';
import '../data/onboarding_repository.dart';
import 'widgets/onboarding_page_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Page View
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              OnboardingPageWidget(
                title: 'Çıkmış Sorular',
                description: 'Geçmiş yılların ehliyet sınav sorularını çözerek gerçek sınav deneyimi yaşayın. Eksiklerinizi görün.',
                icon: Icons.assignment_turned_in_rounded,
                iconColor: AppColors.primary,
              ),
              OnboardingPageWidget(
                title: 'Akıllı Tekrar',
                description: 'Yapay zeka destekli sistem ile hatalarınızı analiz ediyoruz. Sadece eksik olduğunuz konulara odaklanın.',
                icon: Icons.psychology_rounded,
                iconColor: AppColors.secondary,
              ),
              OnboardingPageWidget(
                title: 'İlerleme Takibi',
                description: 'Detaylı grafiklerle gelişiminizi gün gün takip edin. Başarı oranınızı artırın.',
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.premium,
              ),
            ],
          ),

          // Bottom Controls
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip Button
                if (!isLastPage)
                  TextButton(
                    onPressed: () {
                      _pageController.jumpToPage(2);
                    },
                    child: Text(
                      'Atla',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 64), // Placeholder to keep spacing

                // Page Indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: WormEffect(
                    spacing: 16,
                    dotColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    activeDotColor: AppColors.primary,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),

                // Next / Done Button
                if (!isLastPage)
                  TextButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'İleri',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      // Save completion state
                      await ref.read(onboardingRepositoryProvider).setOnboardingComplete();

                      // Navigate to AuthGate
                      if (context.mounted) {
                         Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const AuthGate()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Başla'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
