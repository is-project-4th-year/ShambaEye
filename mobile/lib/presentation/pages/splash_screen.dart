import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'offline_home.dart';
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
          print('⏰ Auth check timed out, proceeding to options screen');
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
      // On error, proceed to options screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashOptionsScreen()),
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
    
    if (authProvider.isLoggedIn) {
      print('🚀 User is logged in, navigating to HomePage');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print('🚀 User not logged in, navigating to options');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashOptionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 100, color: Colors.green[800]),
            const SizedBox(height: 20),
            Text(
              'ShambaEye',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tomato Disease Detector',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 30),
            if (!_authCheckComplete) ...[
              CircularProgressIndicator(color: Colors.green),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                ),
              ),
            ] else if (_initialized && !_authCheckComplete) ...[
              Icon(Icons.warning, color: Colors.orange, size: 40),
              const SizedBox(height: 10),
              Text(
                'Taking longer than expected',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashOptionsScreen()),
                  );
                },
                child: Text('Continue Anyway'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SplashOptionsScreen extends StatelessWidget {
  const SplashOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.agriculture, size: 80, color: Colors.green[800]),
              const SizedBox(height: 30),
              Text(
                'Welcome to ShambaEye',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Detect tomato plant diseases instantly',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              _buildOptionButton(
                context,
                title: 'Continue Offline',
                subtitle: 'Basic disease detection',
                icon: Icons.offline_bolt,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OfflineHome()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildOptionButton(
                context,
                title: 'Login / Sign Up',
                subtitle: 'Full features with history & analysis',
                icon: Icons.cloud,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 32, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}