import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSigningOut = false;

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    setState(() => _isSigningOut = true);
    
    try {
      final authController = ref.read(authControllerProvider);
      final success = await authController.signOut();
      
      if (success && mounted) {
        _showSuccessSnackBar('Başarıyla çıkış yapıldı');
        // Navigate to auth screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      } else {
        _showErrorSnackBar('Çıkış yapılırken bir hata oluştu');
      }
    } catch (e) {
      _showErrorSnackBar('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  Widget _buildGuestProfile() {
    return Column(
      children: [
        const SizedBox(height: 32),
        
        // Guest Icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Misafir Kullanıcı',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'İlerlemenizi kaydetmek ve tüm cihazlarınızda\nsenkronize etmek için giriş yapın.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Sign In Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _navigateToAuth,
            icon: const Icon(Icons.login),
            label: const Text('Giriş Yap'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignedInProfile(String? displayName, String? email, String? photoURL) {
    return Column(
      children: [
        const SizedBox(height: 32),
        
        // Profile Photo
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
            child: photoURL == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // User Name
        Text(
          displayName ?? 'Kullanıcı',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // User Email
        if (email != null) ...[
          Text(
            email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
        
        // Account Status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 128)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_user,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hesabınız doğrulandı ve ilerlemeniz güvende',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Sign Out Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSigningOut ? null : _signOut,
            icon: _isSigningOut
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                    ),
                  )
                : const Icon(Icons.logout),
            label: Text(_isSigningOut ? 'Çıkış yapılıyor...' : 'Çıkış Yap'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final displayName = ref.watch(userDisplayNameProvider);
    final email = ref.watch(userEmailProvider);
    final photoURL = ref.watch(userPhotoURLProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: user == null
              ? _buildGuestProfile()
              : _buildSignedInProfile(displayName, email, photoURL),
        ),
      ),
    );
  }
}