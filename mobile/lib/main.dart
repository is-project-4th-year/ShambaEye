import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/home_page.dart'; // ✅ ADD THIS IMPORT
import 'presentation/pages/auth/login_screen.dart'; // ✅ ADD THIS IMPORT
import 'presentation/pages/offline_home.dart'; // ✅ ADD THIS IMPORT
import 'presentation/providers/analysis_provider.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        title: 'ShambaEye',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF2E7D32),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) => const HomePage(), // ✅ NOW DEFINED
          '/login': (context) => const LoginScreen(), // ✅ NOW DEFINED
          '/offline': (context) => const OfflineHome(), // ✅ NOW DEFINED
        },
      ),
    );
  }
}