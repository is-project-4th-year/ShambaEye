import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // 🆕 ADDED: Prevent overflow
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, authProvider),
              const SizedBox(height: 32),
              
              // Welcome Card
              _buildWelcomeCard(authProvider),
              const SizedBox(height: 32),
              
              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: 32),
              
              // Features Section
              _buildFeaturesSection(context, authProvider.isLoggedIn),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppAuthProvider authProvider) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFD2EFDA), // Light green
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.agriculture,
            color: const Color(0xFF2E7D32), // Dark green
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
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
                    : 'Plant Enthusiast',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20), // Darker green
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFD2EFDA), // Light green
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_outlined, 
                color: const Color(0xFF2E7D32), size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(AppAuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD2EFDA), // Light green background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA8D5BA), // Slightly darker green border
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
              color: const Color(0xFF2E7D32), // Dark green
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              authProvider.isLoggedIn ? 'PREMIUM' : 'BASIC',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Plant Health\nAnalysis',
            style: TextStyle(
              color: Color(0xFF1B5E20), // Dark green
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            authProvider.isLoggedIn 
                ? 'Full access to AI-powered disease detection and analysis tools'
                : 'Upgrade to unlock severity analysis, heatmaps, and history',
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

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Scan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Start analyzing your plants',
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
                title: 'Camera',
                subtitle: 'Take a photo',
                color: const Color(0xFF2E7D32), // Dark green
                onTap: () {
                  // Navigate to camera analysis
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.photo_library_rounded,
                title: 'Gallery',
                subtitle: 'Choose from photos',
                color: const Color(0xFF2E7D32), // Dark green
                onTap: () {
                  // Navigate to gallery analysis
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
          color: const Color(0xFFD2EFDA), // Light green background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFA8D5BA), // Border color
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

  Widget _buildFeaturesSection(BuildContext context, bool isLoggedIn) {
    final List<Map<String, dynamic>> features = isLoggedIn
        ? [
            {
              'icon': Icons.analytics_outlined,
              'title': 'Severity Analysis', 
              'description': 'Detailed disease assessment',
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.heat_pump_outlined, 
              'title': 'Heat Maps', 
              'description': 'Visual disease locations',
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.history_outlined, 
              'title': 'Analysis History', 
              'description': 'Track your plant health',
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.cloud_outlined, 
              'title': 'Cloud Storage', 
              'description': 'Access anywhere, anytime',
              'color': const Color(0xFF2E7D32),
            },
          ]
        : [
            {
              'icon': Icons.analytics_outlined, 
              'title': 'Basic Detection', 
              'description': 'Essential disease identification',
              'color': const Color(0xFF2E7D32),
            },
            {
              'icon': Icons.lock_outline, 
              'title': 'Severity Analysis', 
              'description': 'Upgrade to unlock',
              'color': Colors.grey,
            },
            {
              'icon': Icons.lock_outline, 
              'title': 'Heat Maps', 
              'description': 'Upgrade to unlock',
              'color': Colors.grey,
            },
            {
              'icon': Icons.lock_outline, 
              'title': 'Full History', 
              'description': 'Upgrade to unlock',
              'color': Colors.grey,
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isLoggedIn ? 'All features unlocked' : 'Upgrade for more features',
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1, // 🆕 ADJUSTED: Better aspect ratio
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[200] : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : icon,
                  color: isLocked ? Colors.grey : color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey : color,
                ),
              ),
            ],
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isLocked ? Colors.grey[500] : color.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}