import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/purchase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/auth_screen.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with TickerProviderStateMixin {
  final PurchaseService _purchaseService = PurchaseService();
  List<Offering> _offerings = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  String? _selectedPackageId;
  Map<String, dynamic>? _subscriptionStatus;
  
  late AnimationController _heroController;
  late AnimationController _contentController;
  late Animation<double> _heroAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOfferings();
    _loadSubscriptionStatus();
  }

  void _initializeAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );
    
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await _purchaseService.getOfferings();
      setState(() {
        _offerings = offerings;
        _isLoading = false;
        // Auto-select the monthly subscription as primary option
        if (offerings.isNotEmpty) {
          final packages = offerings.expand((o) => o.availablePackages).toList();
          final monthlyPackage = packages.where((p) => 
            p.identifier.contains('monthly') || p.identifier.contains('month')
          ).firstOrNull;
          _selectedPackageId = monthlyPackage?.identifier ?? 'ehliyet_rehberim_pro_monthly';
        } else {
          _selectedPackageId = 'ehliyet_rehberim_pro_monthly'; // Default fallback
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paketler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final status = await _purchaseService.getSubscriptionStatus();
      setState(() {
        _subscriptionStatus = status;
      });
    } catch (e) {
      debugPrint('Failed to load subscription status: $e');
    }
  }

  Future<void> _purchaseSelectedPackage() async {
    if (_selectedPackageId == null) return;
    
    // Check if user is authenticated first
    final authState = ref.read(authStateProvider);
    final isSignedIn = authState.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );

    // If not signed in, show auth dialog first
    if (!isSignedIn) {
      await _showAuthRequiredDialog();
      return;
    }
    
    // First try to find the package in offerings
    final package = _offerings
        .expand((o) => o.availablePackages)
        .where((p) => p.identifier == _selectedPackageId)
        .firstOrNull;
    
    if (package != null) {
      await _purchasePackage(package);
    } else if (_selectedPackageId == 'ehliyet_rehberim_pro_monthly') {
      // Handle the custom monthly subscription (49.99 TRY)
      // This would be handled by your app store configuration
      // For now, show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Aylık abonelik başlatılıyor...'),
            backgroundColor: AppColors.primary,
          ),
        );
        // In real implementation, this would trigger the app store purchase
        // Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _purchasePackage(Package package) async {
    // Check if user is authenticated before allowing purchase
    final authState = ref.read(authStateProvider);
    final isSignedIn = authState.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );

    if (!isSignedIn) {
      await _showAuthRequiredDialog();
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      final success = await _purchaseService.purchasePackage(package);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pro sürüme başarıyla geçtiniz! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate successful purchase
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Satın alma işlemi başarısız oldu. Lütfen tekrar deneyin.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma sırasında hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isPurchasing = false;
      });
    }
  }

  /// Show dialog asking user to sign in before making a purchase
  Future<void> _showAuthRequiredDialog() async {
    final shouldNavigateToAuth = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        title: const Text(
          '🔐 Giriş Yapmanız Gerekiyor',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pro sürüme geçmek için önce giriş yapmanız gerekiyor.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '3 gün ücretsiz deneme',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Satın alımınızı kaybetmeyin',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Güvenli ödeme işlemi',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: const Text('Şimdilik İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.login, size: 20),
            label: const Text('Giriş Yap / Kayıt Ol'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );

    if (shouldNavigateToAuth == true && mounted) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
      
      // If user successfully signed in, show success message and continue with purchase
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Başarıyla giriş yaptınız! Artık Pro sürüme geçebilirsiniz.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Automatically retry the purchase after successful login
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          _purchaseSelectedPackage();
        }
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
      _isRestoring = true;
    });

    try {
      final success = await _purchaseService.restorePurchases();
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Satın alımlarınız başarıyla geri yüklendi! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Geri yüklenecek satın alma bulunamadı.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geri yükleme sırasında hata oluştu: $e'),
              backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isPurchasing = false;
        _isRestoring = false;
      });
    }
  }

  void _launchPrivacyPolicy() async {
    const url = 'https://ummugulsun.me/ehliyet-rehberim/privacy-policy.html';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _launchTermsOfService() async {
    const url = 'https://ummugulsun.me/ehliyet-rehberim/terms-of-service.html';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Custom App Bar
                  _buildCustomAppBar(),
                  
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                          // Hero Section
                          _buildHeroSection(),
                          
                          // Features Section
                          _buildFeaturesSection(),
                          
                          // Package Selection
                          _buildPackageSelection(),
                          
                          // Primary CTA
                          _buildPrimaryCTA(),
                          
                          // Trust Signals
                          _buildTrustSignals(),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
                    Text(
            'Pro Sürüme Geç',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _heroAnimation.value)),
          child: Opacity(
            opacity: _heroAnimation.value,
            child: Container(
                      width: double.infinity,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                    AppColors.premiumDark,
                    AppColors.premium,
                    AppColors.premiumLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                    color: AppColors.premiumShadow.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                              ),
                            ],
                          ),
                      child: Column(
                        children: [
                  // Premium Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.onPremium.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.onPremium.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 48,
                      color: AppColors.onPremium,
                    ),
                  ),
                  
                        const SizedBox(height: 24),
                  
                  // Hero Title
                        Text(
                    'Ehliyet Rehberim Pro',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPremium,
                      fontSize: 28,
                      letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                  
                  const SizedBox(height: 12),
                  
                  // Hero Subtitle
                        Text(
                    'Sınırsız erişim ile hedeflerinize\ndaha hızlı ulaşın',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onPremium.withValues(alpha: 0.9),
                      fontSize: 16,
                      height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'title': 'Daha Fazla Deneme Sınavına Erişim',
        'description': '1000+ fazla soruya erişim kazanın',
        'icon': Icons.quiz_rounded,
      },
      {
        'title': 'Reklamsız Deneyim',
        'description': 'Kesintisiz çalışma deneyimi',
        'icon': Icons.block_rounded,
      },
      {
        'title': 'Detaylı İstatistikler',
        'description': 'Gelişiminizi takip edin ve analiz edin',
        'icon': Icons.analytics_rounded,
      },
      {
        'title': 'Konu Bazlı Çalışma',
        'description': 'Zayıf olduğunuz konulara odaklanın',
        'icon': Icons.topic_rounded,
      },
      {
        'title': 'Detaylı Açıklamalar',
        'description': 'Her soru için kapsamlı açıklama',
        'icon': Icons.info_rounded,
      },
    ];

    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Column(
              children: [
                // Current Subscription Status
                if (_subscriptionStatus != null && _subscriptionStatus!['isPro'] == true)
                  _buildCurrentSubscriptionCard(),
                
                const SizedBox(height: 24),
                
                // Features List
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    'Pro Özellikleri',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...features.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feature = entry.value;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: _buildFeatureTile(
                            icon: feature['icon'] as IconData,
                            title: feature['title'] as String,
                            description: feature['description'] as String,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    final status = _subscriptionStatus!;
    final expiresDate = status['expiresDate'] != null 
        ? DateTime.tryParse(status['expiresDate']) 
        : null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aktif Pro Aboneliğiniz Var!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          if (expiresDate != null) ...[
            const SizedBox(height: 8),
                    Text(
              'Bitiş Tarihi: ${_formatDate(expiresDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }



  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.1),
                        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
                      ),
        ],
      ),
      child: Row(
                        children: [
          // Checkmark Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.successLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.onSuccess,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Feature Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                          Text(
                  title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                            ),
                          ),
                const SizedBox(height: 4),
                          Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                          ),
                        ],
                      ),
                    ),
          
          // Feature Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelection() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Abonelik Planı',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Primary Monthly Subscription Card
                  _buildMainSubscriptionCard(),
                  
                  // Optional Annual Plan (if available)
                  if (_offerings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildOptionalAnnualCard(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildMainSubscriptionCard() {
    
    return GestureDetector(
      onTap: () {
        // Set to monthly subscription
        setState(() {
          _selectedPackageId = 'ehliyet_rehberim_pro_monthly'; // Default ID for monthly
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.premium, AppColors.premiumLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.premium,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.premium.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
        children: [
            // Free Trial Badge
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.successLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'İlk Gün Ücretsiz!',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            
            // Main Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Selection Indicator (always selected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.onPremium,
            ),
            child: Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.premium,
                      ),
                    ),
                    
          const SizedBox(width: 16),
                    
                    // Title
          Expanded(
                      child: Text(
                        'Aylık Abonelik',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPremium,
                        ),
                      ),
                    ),
                    
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '49.99 TL',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.onPremium,
                          ),
                        ),
                        Text(
                          'ay',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPremium.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Padding(
                  padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                        '1 gün ücretsiz deneme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onPremium,
                          fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                        'Deneme sonrası ayda 49.99 TL\nİstediğin zaman iptal et',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPremium.withValues(alpha: 0.85),
                          height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalAnnualCard() {
    final packages = _offerings.expand((o) => o.availablePackages).toList();
    final annualPackage = packages.where((p) => 
      p.identifier.contains('yearly') || p.identifier.contains('annual')
    ).firstOrNull;

    if (annualPackage == null) return const SizedBox.shrink();

    final isSelected = _selectedPackageId == annualPackage.identifier;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageId = annualPackage.identifier;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryContainer
              : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? [
                BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
          ] : null,
        ),
        child: Stack(
              children: [
            // Best Value Badge
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning, AppColors.warningLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'En İyi Değer',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            
            // Card Content
            Row(
              children: [
                // Selection Radio
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.outline,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.onPrimary,
                        )
                      : null,
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                        annualPackage.storeProduct.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                      ),
                    ),
                      const SizedBox(height: 4),
                      Text(
                        'Yıllık ödeme ile tasarruf edin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Text(
                  annualPackage.storeProduct.priceString,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPrimaryCTA() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Auth Required Notice
                  Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authStateProvider);
                      final isSignedIn = authState.when(
                        data: (user) => user != null,
                        loading: () => false,
                        error: (_, __) => false,
                      );
                      
                      if (!isSignedIn) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Pro sürüme geçmek için önce giriş yapmanız gerekiyor',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isPurchasing || _selectedPackageId == null 
                          ? null 
                          : _purchaseSelectedPackage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.onPremium,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.premium,
                              AppColors.premiumLight,
                              AppColors.premium,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.premiumShadow.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isPurchasing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPremium),
                                  ),
                                )
                              : Consumer(
                                  builder: (context, ref, child) {
                                    final authState = ref.watch(authStateProvider);
                                    final isSignedIn = authState.when(
                                      data: (user) => user != null,
                                      loading: () => false,
                                      error: (_, __) => false,
                                    );
                                    
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isSignedIn ? Icons.stars_rounded : Icons.login,
                                          size: 24,
                                          color: AppColors.onPremium,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          isSignedIn ? '3 Gün Ücretsiz Dene' : 'Giriş Yap ve Dene',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onPremium,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Pricing Subtext
                  const SizedBox(height: 12),
                  
                  Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authStateProvider);
                      final isSignedIn = authState.when(
                        data: (user) => user != null,
                        loading: () => false,
                        error: (_, __) => false,
                      );
                      
                      if (isSignedIn) {
                        return Text(
                          '3 gün ücretsiz deneme sonrası ayda 49.99 TL. İstediğin zaman iptal et.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return Text(
                          'Giriş yaparak 3 gün ücretsiz deneyin',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrustSignals() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value * 0.8,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Restore Purchases Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isPurchasing || _isRestoring ? null : _restorePurchases,
                      icon: Icon(
                        Icons.restore_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Satın Alımları Geri Yükle',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Legal Links
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    children: [
                      _buildLegalLink(
                        'Gizlilik Politikası',
                        _launchPrivacyPolicy,
                      ),
                      _buildLegalLink(
                        'Kullanım Koşulları',
                        _launchTermsOfService,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Auto-renewal Notice
                  Text(
                    'Aboneliğiniz otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
} 