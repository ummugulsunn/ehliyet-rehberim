import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/application/theme_mode_provider.dart';
import '../../auth/application/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link açılamadı: $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildUserHeader() {
    final authState = ref.watch(authStateProvider);
    final userDisplayName = ref.watch(userDisplayNameProvider);
    final userEmail = ref.watch(userEmailProvider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: authState.when(
        data: (user) => user != null
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: user.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userDisplayName ?? 'Kullanıcı',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.premium,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pro',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Misafir Kullanıcı',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Giriş yaparak daha fazla özellik keşfedin',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor ?? AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.textSecondary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ?? 
          (onTap != null 
              ? Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                )
              : null),
    );
  }

  Widget _buildThemeSelector() {
    final currentThemeMode = ref.watch(themeModeProvider);
    
    return _buildSettingsTile(
      icon: currentThemeMode == ThemeMode.dark 
          ? Icons.dark_mode 
          : currentThemeMode == ThemeMode.light 
              ? Icons.light_mode 
              : Icons.brightness_auto,
      title: 'Tema',
      subtitle: currentThemeMode == ThemeMode.dark 
          ? 'Koyu tema' 
          : currentThemeMode == ThemeMode.light 
              ? 'Açık tema' 
              : 'Sistem teması',
      iconColor: AppColors.warning,
      trailing: DropdownButton<ThemeMode>(
        value: currentThemeMode,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('Sistem'),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text('Açık'),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text('Koyu'),
          ),
        ],
        onChanged: (ThemeMode? mode) {
          if (mode != null) {
            ref.read(themeModeProvider.notifier).setThemeMode(mode);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Header
            _buildUserHeader(),

            // Appearance Settings
            _buildSettingsCard(
              title: 'Görünüm',
              icon: Icons.palette,
              iconColor: AppColors.warning,
              children: [
                _buildThemeSelector(),
              ],
            ),

            // Account Settings
            _buildSettingsCard(
              title: 'Hesap',
              icon: Icons.person,
              iconColor: AppColors.success,
              children: [
                _buildSettingsTile(
                  icon: Icons.account_circle,
                  title: 'Profil Bilgileri',
                  subtitle: 'Hesap bilgilerinizi düzenleyin',
                  onTap: () {
                    // Navigate to profile screen
                  },
                  iconColor: AppColors.primary,
                ),
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Bildirimler',
                  subtitle: 'Bildirim tercihlerinizi ayarlayın',
                  onTap: () {
                    // Navigate to notifications settings
                  },
                  iconColor: AppColors.info,
                ),
              ],
            ),

            // Legal Settings
            _buildSettingsCard(
              title: 'Yasal',
              icon: Icons.gavel,
              iconColor: AppColors.info,
              children: [
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Gizlilik Politikası',
                  subtitle: 'Verilerinizin nasıl korunduğunu öğrenin',
                  onTap: () => _launchURL('https://ummugulsunn.github.io/ummugulsun-portfolio/ehliyet-rehberim/privacy-policy.html'),
                  iconColor: AppColors.error,
                ),
                _buildSettingsTile(
                  icon: Icons.description,
                  title: 'Kullanım Şartları',
                  subtitle: 'Hizmet kullanım koşullarını inceleyin',
                  onTap: () => _launchURL('https://ummugulsunn.github.io/ummugulsun-portfolio/ehliyet-rehberim/terms-of-service.html'),
                  iconColor: AppColors.warning,
                ),
              ],
            ),

            // Support Settings
            _buildSettingsCard(
              title: 'Destek',
              icon: Icons.help,
              iconColor: AppColors.success,
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Yardım ve Destek',
                  subtitle: 'Sıkça sorulan sorular ve yardım',
                  onTap: () => _launchURL('mailto:ugturkmen.dev@gmail.com?subject=Ehliyet Rehberim - Destek'),
                  iconColor: AppColors.success,
                ),
                _buildSettingsTile(
                  icon: Icons.bug_report,
                  title: 'Hata Bildir',
                  subtitle: 'Karşılaştığınız sorunları bildirin',
                  onTap: () => _launchURL('mailto:ugturkmen.dev@gmail.com?subject=Ehliyet Rehberim - Hata Raporu'),
                  iconColor: AppColors.error,
                ),
                _buildSettingsTile(
                  icon: Icons.star,
                  title: 'Uygulamayı Değerlendir',
                  subtitle: 'App Store\'da puan verin',
                  onTap: () => _launchURL('https://apps.apple.com/us/app/ehliyet-rehberim/id6739002862'),
                  iconColor: AppColors.warning,
                ),
              ],
            ),

            // About Settings
            _buildSettingsCard(
              title: 'Hakkında',
              icon: Icons.info,
              iconColor: AppColors.textSecondary,
              children: [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'Uygulama Versiyonu',
                  subtitle: _appVersion.isNotEmpty ? _appVersion : 'Yükleniyor...',
                  iconColor: AppColors.textSecondary,
                ),
                _buildSettingsTile(
                  icon: Icons.code,
                  title: 'Geliştirici',
                  subtitle: 'TurkmenApps',
                  onTap: () => _launchURL('mailto:ugturkmen.dev@gmail.com'),
                  iconColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}