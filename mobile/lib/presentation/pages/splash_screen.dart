import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart'; // 🆕 ADD THIS IMPORT
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialized = false;
  bool _authCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🔄 Starting app initialization...');
      
      // Add a minimum splash screen duration
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check auth status with timeout
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      
      // Use a timeout to prevent hanging
      final authCheck = authProvider.checkAuthStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏰ Auth check timed out, proceeding to main screen');
          return; // Return gracefully on timeout
        },
      );

      await authCheck;
      
      setState(() {
        _authCheckComplete = true;
      });

      print('✅ Auth check completed, navigating...');
      _navigateToNextScreen(authProvider);
      
    } catch (e) {
      print('❌ Error during app initialization: $e');
      // On error, proceed to main screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } finally {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _navigateToNextScreen(AppAuthProvider authProvider) {
    if (!mounted) return;
    
    // 🆕 UPDATED: Always navigate to MainScreen, which handles online/offline mode internally
    print('🚀 Navigating to MainScreen');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🆕 UPDATED: White background for modern look
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🆕 UPDATED: Modern logo design
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.agriculture,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            // 🆕 UPDATED: Modern typography
            Text(
              'ShambaEye',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.green[800],
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tomato Disease Detector',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            // 🆕 UPDATED: Modern loading indicator
            if (!_authCheckComplete) ...[
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                  backgroundColor: Colors.green[100],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Preparing your experience...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else if (_initialized && !_authCheckComplete) ...[
              // 🆕 UPDATED: Modern timeout UI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.orange[700], size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'Connection Issue',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Starting in offline mode',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('CONTINUE'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 🆕 REMOVED: SplashOptionsScreen - No longer needed since we go directly to MainScreen