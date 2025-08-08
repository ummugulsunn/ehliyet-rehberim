import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/services/purchase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/auth_screen.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  List<Offering> _offerings = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await _purchaseService.getOfferings();
      setState(() {
        _offerings = offerings;
        _isLoading = false;
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
        icon: Icon(
          Icons.account_circle_outlined,
          size: 48,
          color: AppColors.primary,
        ),
        title: const Text('Giriş Yapın'),
        content: const Text(
          'Satın alımınızı tüm cihazlarınızda senkronize etmek ve kaybetmemek için lütfen giriş yapın veya hesap oluşturun.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );

    if (shouldNavigateToAuth == true && mounted) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
      
      // If user successfully signed in, show success message
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Başarıyla giriş yaptınız! Artık satın alma yapabilirsiniz.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Sürüme Geç'),
                  backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.secondary,
                                AppColors.secondaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryShadow,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.star,
                            size: 60,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Pro Sürüme Geç',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tüm özelliklerin kilidini açın',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Features Section
                  Text(
                    'Pro Özellikleri',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureItem(
                    icon: Icons.quiz,
                    title: 'Tüm Sorulara Erişim',
                    description: '1000+ soru ile sınırsız pratik yapın',
                  ),
                  _buildFeatureItem(
                    icon: Icons.block,
                    title: 'Reklamsız Deneyim',
                    description: 'Kesintisiz çalışma deneyimi',
                  ),
                  _buildFeatureItem(
                    icon: Icons.analytics,
                    title: 'Detaylı İstatistikler',
                    description: 'Gelişiminizi takip edin',
                  ),
                  _buildFeatureItem(
                    icon: Icons.info_outline,
                    title: 'Detaylı Açıklamalar',
                    description: 'Her soru için kapsamlı açıklama',
                  ),
                  _buildFeatureItem(
                    icon: Icons.topic,
                    title: 'Konu Bazlı Çalışma',
                    description: 'Zayıf olduğunuz konulara odaklanın',
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Subscription Options
                  if (_offerings.isNotEmpty) ...[
                    Text(
                      'Abonelik Seçenekleri',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ..._offerings.expand((offering) => offering.availablePackages).map((package) {
                      return _buildPackageCard(package);
                    }),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Paketler Yüklenemedi',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Restore Purchases Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isPurchasing ? null : _restorePurchases,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Satın Alımları Geri Yükle'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Terms and Privacy
                  Text(
                    'Aboneliğiniz otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final isPopular = package.identifier.contains('yearly') || package.identifier.contains('annual');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPopular ? null : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: isPopular
            ? null
            : Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isPurchasing ? null : () => _purchasePackage(package),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.storeProduct.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPopular ? Theme.of(context).colorScheme.onPrimary : null,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'POPÜLER',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.storeProduct.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isPopular ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 204) : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package.storeProduct.priceString,
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPopular ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                        ),
                    ),
                    if (package.storeProduct.introductoryPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${package.storeProduct.introductoryPrice?.priceString ?? ''} ilk dönem',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPopular ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 204) : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 