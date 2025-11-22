import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/image_selection_view.dart';
import '../widgets/analysis_view.dart';
import 'auth/login_screen.dart';
import 'offline_home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShambaEye'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          // Show user info if logged in, otherwise show login option
          if (authProvider.isLoggedIn && authProvider.userProfile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text(
                    authProvider.userProfile!.fullName.split(' ').first,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              tooltip: 'Login for more features',
            ),
          
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAppInfo(context, authProvider.isLoggedIn);
            },
          ),
          
          // Logout option for logged-in users
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
        ],
      ),
      body: _buildBody(context),
      // 🆕 UPDATED: More useful floating action buttons
      floatingActionButton: authProvider.isLoggedIn 
          ? _buildOnlineFeaturesFab(context) // Show features available
          : _buildUpgradeFab(context), // Encourage login
    );
  }

  // 🆕 NEW: Better body structure with back navigation
  Widget _buildBody(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.imagePath == null) {
          return const ImageSelectionView();
        } else {
          return Stack(
            children: [
              AnalysisView(), // ✅ REMOVED const
              // 🆕 ADD: Back button to return to image selection
              Positioned(
                top: 16,
                left: 16,
                child: FloatingActionButton.small(
                  onPressed: () {
                    provider.clearResults();
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[700],
                  child: const Icon(Icons.arrow_back),
                  tooltip: 'Back to image selection',
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // 🆕 NEW: FAB for logged-in users - shows available features
  Widget _buildOnlineFeaturesFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showOnlineFeatures(context);
      },
      icon: Icon(Icons.workspace_premium, color: Colors.white),
      label: Text('Premium Features', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
      tooltip: 'View all online features',
    );
  }

  // 🆕 NEW: FAB for non-logged-in users - encourages upgrade
  Widget _buildUpgradeFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      icon: Icon(Icons.upgrade, color: Colors.white),
      label: Text('Go Premium', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blue,
      tooltip: 'Login for premium features',
    );
  }

  // 🆕 NEW: Show online features available
  void _showOnlineFeatures(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.green),
            SizedBox(width: 8),
            Text('Premium Features Active'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureItem('🎯 Severity Analysis', 'Get detailed disease severity levels'),
            _buildFeatureItem('🔥 Grad-CAM Heatmaps', 'Visualize affected areas in images'),
            _buildFeatureItem('☁️ Cloud History', 'Access your analysis history anywhere'),
            _buildFeatureItem('📊 Advanced Analytics', 'Detailed treatment recommendations'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context, bool isOnline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ShambaEye ${isOnline ? 'Premium' : 'Basic'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Plan: ${isOnline ? 'Premium 🌟' : 'Basic 📱'}'),
            SizedBox(height: 12),
            Text(isOnline 
              ? '✅ Disease Detection\n✅ Severity Analysis\n✅ Grad-CAM Heatmaps\n✅ Cloud History'
              : '✅ Disease Detection\n❌ Severity Analysis\n❌ Grad-CAM Heatmaps\n❌ Cloud History'
            ),
            SizedBox(height: 12),
            if (!isOnline)
              Text(
                'Upgrade to Premium for advanced features!',
                style: TextStyle(color: Colors.orange[700]),
              ),
          ],
        ),
        actions: [
          if (!isOnline)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('UPGRADE'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Switch to Basic?'),
        content: Text('You will lose access to premium features:\n\n• Severity Analysis\n• Grad-CAM Heatmaps\n• Cloud History'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('STAY PREMIUM'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AppAuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OfflineHome()),
              );
            },
            child: Text('SWITCH TO BASIC'),
          ),
        ],
      ),
    );
  }
}