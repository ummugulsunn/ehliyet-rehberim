import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../../features/paywall/presentation/paywall_screen.dart';

class EnhancedProBanner extends StatefulWidget {
  const EnhancedProBanner({super.key});

  @override
  State<EnhancedProBanner> createState() => _EnhancedProBannerState();
}

class _EnhancedProBannerState extends State<EnhancedProBanner>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _gradientController;
  late AnimationController _starController;
  late AnimationController _arrowController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<double> _starScaleAnimation;
  late Animation<double> _starRotationAnimation;
  late Animation<double> _arrowBounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Glow animation - subtle pulsing
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Moving gradient animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.linear,
      ),
    );

    // Star animation - subtle scale and rotation
    _starController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _starScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.easeInOut,
      ),
    );
    _starRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.easeInOut,
      ),
    );

    // Arrow bounce animation
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _arrowBounceAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _arrowController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _startAnimations() {
    // Start repeating animations
    _glowController.repeat(reverse: true);
    _gradientController.repeat();
    _starController.repeat(reverse: true);
    
    // Delayed arrow animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _arrowController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _gradientController.dispose();
    _starController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowController,
        _gradientController,
        _starController,
        _arrowController,
      ]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Enhanced shadow with glow effect
              BoxShadow(
                color: AppColors.premiumShadow.withValues(alpha: _glowAnimation.value * 0.4),
                blurRadius: 20 + (_glowAnimation.value * 10),
                offset: const Offset(0, 8),
                spreadRadius: _glowAnimation.value * 2,
              ),
              // Additional inner glow
              BoxShadow(
                color: AppColors.premium.withValues(alpha: _glowAnimation.value * 0.2),
                blurRadius: 30,
                offset: const Offset(0, 0),
                spreadRadius: _glowAnimation.value * 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                // Animated gradient background
                gradient: LinearGradient(
                  colors: [
                    _getAnimatedColor(AppColors.premiumDark, AppColors.premium),
                    _getAnimatedColor(AppColors.premium, AppColors.premiumLight),
                    _getAnimatedColor(AppColors.premiumLight, AppColors.premium),
                  ],
                  stops: [
                    math.max(0.0, _gradientAnimation.value - 0.3),
                    _gradientAnimation.value,
                    math.min(1.0, _gradientAnimation.value + 0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
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
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Animated star icon container
                        _buildAnimatedStarIcon(),
                        const SizedBox(width: 20),
                        
                        // Enhanced text content
                        Expanded(child: _buildTextContent(context)),
                        
                        // Animated arrow indicator
                        _buildAnimatedArrow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStarIcon() {
    return Transform.scale(
      scale: _starScaleAnimation.value,
      child: Transform.rotate(
        angle: _starRotationAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.onPremium.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.onPremium.withValues(alpha: 0.4),
              width: 1.5,
            ),
            // Additional glow for star container
            boxShadow: [
              BoxShadow(
                color: AppColors.onPremium.withValues(alpha: _glowAnimation.value * 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            color: AppColors.onPremium,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced main title with glow effect
        AnimatedOpacity(
          opacity: 0.7 + (_glowAnimation.value * 0.3),
          duration: const Duration(milliseconds: 100),
          child: Text(
            'Pro Sürüme Geç',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onPremium,
              fontSize: 22,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: AppColors.onPremium.withValues(alpha: _glowAnimation.value * 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        
        // Subtitle
        Text(
          'Tüm özelliklerin kilidini açın',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onPremium.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        
        // Enhanced benefits row with icons
        _buildBenefitsRow(context),
      ],
    );
  }

  Widget _buildBenefitsRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use Wrap to avoid horizontal overflow on small screens
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildBenefitItem(Icons.quiz_outlined, '20 Deneme'),
            _buildBenefitItem(Icons.block, 'Reklamsız'),
            _buildBenefitItem(Icons.insights, 'Detaylı analiz'),
          ],
        );
      },
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.onPremium.withValues(alpha: 0.9),
          size: 16,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.onPremium.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedArrow() {
    return Transform.translate(
      offset: Offset(_arrowBounceAnimation.value, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.onPremium.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.onPremium.withValues(alpha: 0.4),
            width: 1,
          ),
          // Glow effect for arrow
          boxShadow: [
            BoxShadow(
              color: AppColors.onPremium.withValues(alpha: _glowAnimation.value * 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.onPremium,
          size: 18,
        ),
      ),
    );
  }

  Color _getAnimatedColor(Color startColor, Color endColor) {
    return Color.lerp(
      startColor,
      endColor,
      (math.sin(_gradientAnimation.value * 2 * math.pi) + 1) / 2,
    )!;
  }
}
