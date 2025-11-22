import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import 'package:shamba_eye/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, authProvider, locale),
              const SizedBox(height: 32),
              
              // Welcome Card
              _buildWelcomeCard(authProvider, locale),
              const SizedBox(height: 32),
              
              // Quick Actions
              _buildQuickActions(context, locale),
              const SizedBox(height: 32),
              
              // Features Section
              _buildFeaturesSection(context, authProvider.isLoggedIn, locale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppAuthProvider authProvider, AppLocalizations locale) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFD2EFDA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.agriculture,
            color: const Color(0xFF2E7D32),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.welcome_back,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                authProvider.isLoggedIn && authProvider.userProfile != null
                    ? authProvider.userProfile!.fullName.split(' ').first
                    : locale.plant_enthusiast,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFD2EFDA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF2E7D32), size: 20),
            onPressed: () => _showLanguageSelector(context, locale),
          ),
        ),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context, AppLocalizations locale) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  locale.language,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              // English Option
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF2E7D32)),
                title: Text(locale.english),
                trailing: localeProvider.currentLanguageCode == 'en' 
                    ? const Icon(Icons.check, color: Color(0xFF2E7D32))
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.of(ctx).pop();
                },
              ),
              // Swahili Option
              ListTile(
                leading: const Icon(Icons.translate, color: Color(0xFF2E7D32)),
                title: Text(locale.swahili),
                trailing: localeProvider.currentLanguageCode == 'sw' 
                    ? const Icon(Icons.check, color: Color(0xFF2E7D32))
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('sw'));
                  Navigator.of(ctx).pop();
                },
              ),
              // System Default Option
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF2E7D32)),
                title: Text(locale.system_default),
                trailing: localeProvider.isUsingSystemDefault
                    ? const Icon(Icons.check, color: Color(0xFF2E7D32))
                    : null,
                onTap: () {
                  localeProvider.clearLocale();
                  Navigator.of(ctx).pop();
                },
              ),
              // Info text for logged-in users
              if (authProvider.isLoggedIn) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    locale.language_preference_saved,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(AppAuthProvider authProvider, AppLocalizations locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD2EFDA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA8D5BA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              authProvider.isLoggedIn ? locale.premium : locale.basic,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            locale.plant_health_analysis,
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            authProvider.isLoggedIn 
                ? locale.premium_description
                : locale.basic_description,
            style: TextStyle(
              color: const Color(0xFF1B5E20).withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.quick_scan,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          locale.quick_scan_sub,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.photo_camera_rounded,
                title: locale.camera,
                subtitle: locale.take_photo,
                color: const Color(0xFF2E7D32),
                onTap: () {
                  // Navigate to camera analysis
                  _showComingSoonSnackbar(context, locale);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.photo_library_rounded,
                title: locale.gallery,
                subtitle: locale.choose_photo,
                color: const Color(0xFF2E7D32),
                onTap: () {
                  // Navigate to gallery analysis
                  _showComingSoonSnackbar(context, locale);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFD2EFDA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFA8D5BA),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isLoggedIn, AppLocalizations locale) {
    final List<Map<String, dynamic>> features = isLoggedIn
        ? [
            {
              'icon': Icons.analytics_outlined,
              'title': locale.severity_analysis, 
              'description': locale.severity_desc,
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.heat_pump_outlined, 
              'title': locale.heat_maps, 
              'description': locale.heatmaps_desc,
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.history_outlined, 
              'title': locale.analysis_history, 
              'description': locale.analysis_history_desc,
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.cloud_outlined, 
              'title': locale.cloud_storage, 
              'description': locale.cloud_desc,
              'color': const Color(0xFF2E7D32),
            },
          ]
        : [
            {
              'icon': Icons.analytics_outlined, 
              'title': locale.basic_detection, 
              'description': locale.basic_detection_desc,
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.lock_outline, 
              'title': locale.severity_analysis, 
              'description': locale.upgrade_to_unlock,
              'color': Colors.grey,
            },
            {
              'icon': Icons.lock_outline, 
              'title': locale.heat_maps, 
              'description': locale.upgrade_to_unlock,
              'color': Colors.grey,
            },
            {
              'icon': Icons.lock_outline, 
              'title': locale.analysis_history, 
              'description': locale.upgrade_to_unlock,
              'color': Colors.grey,
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.features,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isLoggedIn ? locale.features_unlocked : locale.features_locked,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
              color: feature['color'] as Color,
              isLocked: !isLoggedIn && index > 0,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[50] : const Color(0xFFD2EFDA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? Colors.grey[200]! : const Color(0xFFA8D5BA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[200] : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : icon,
                  color: isLocked ? Colors.grey : color,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey : color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: isLocked ? Colors.grey[500] : color.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, AppLocalizations locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(locale.feature_coming_soon),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}