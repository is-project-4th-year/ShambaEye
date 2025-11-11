import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AnalysisScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(authProvider.isLoggedIn),
    );
  }

  Widget _buildBottomNavigationBar(bool isLoggedIn) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 0
                  ? BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                Icons.home_outlined,
                size: 24,
                color: _currentIndex == 0 ? const Color(0xFF2E7D32) : Colors.grey[600],
              ),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.home_rounded,
                size: 24,
                color: Color(0xFF2E7D32),
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 1
                  ? BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                Icons.photo_camera_outlined,
                size: 24,
                color: _currentIndex == 1 ? const Color(0xFF2E7D32) : Colors.grey[600],
              ),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_camera_rounded,
                size: 24,
                color: Color(0xFF2E7D32),
              ),
            ),
            label: 'Analyze',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 2
                  ? BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                isLoggedIn ? Icons.history_outlined : Icons.lock_outline,
                size: 24,
                color: _currentIndex == 2 ? const Color(0xFF2E7D32) : Colors.grey[600],
              ),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLoggedIn ? Icons.history_rounded : Icons.lock_rounded,
                size: 24,
                color: const Color(0xFF2E7D32),
              ),
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 3
                  ? BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                Icons.person_outlined,
                size: 24,
                color: _currentIndex == 3 ? const Color(0xFF2E7D32) : Colors.grey[600],
              ),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 24,
                color: Color(0xFF2E7D32),
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}