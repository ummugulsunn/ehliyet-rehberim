import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/auth_providers.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/theme/app_colors.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

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

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      final authController = ref.read(authControllerProvider);
      final success = await authController.signInWithGoogle();
      
      if (success) {
        _navigateToHome();
      } else {
        _showErrorSnackBar('Google ile giriş yapılamadı. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      _showErrorSnackBar('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isAppleLoading = true);
    
    try {
      final authController = ref.read(authControllerProvider);
      final success = await authController.signInWithApple();
      
      if (success) {
        _navigateToHome();
      } else {
        _showErrorSnackBar('Apple ile giriş yapılamadı. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      _showErrorSnackBar('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  void _continueAsGuest() {
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // App Logo and Title
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Ehliyet Rehberim',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sınav Soruları 2026',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const Spacer(flex: 3),
              
              // Welcome Message
              Column(
                children: [
                  Text(
                    'Hoş Geldiniz!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'İlerlemenizi kaydetmek ve tüm cihazlarınızda senkronize etmek için giriş yapın.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Authentication Buttons
              Column(
                children: [
                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isGoogleLoading || _isAppleLoading ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.outline, width: 1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isGoogleLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            )
                          : Icon(
                              Icons.login,
                              size: 20,
                              color: AppColors.primary,
                            ),
                      label: Text(
                        _isGoogleLoading ? 'Giriş yapılıyor...' : 'Google ile Giriş Yap',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Apple Sign-In Button (iOS only)
                  if (Platform.isIOS) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isGoogleLoading || _isAppleLoading ? null : _signInWithApple,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: AppColors.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: _isAppleLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                                ),
                              )
                            : Icon(
                                Icons.apple,
                                size: 20,
                                color: AppColors.surface,
                              ),
                        label: Text(
                          _isAppleLoading ? 'Giriş yapılıyor...' : 'Apple ile Giriş Yap',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
              
              const Spacer(flex: 2),
              
              // Continue as Guest Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextButton(
                  onPressed: _isGoogleLoading || _isAppleLoading ? null : _continueAsGuest,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Misafir olarak devam et',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Privacy Note
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Giriş yaparak Kullanım Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}