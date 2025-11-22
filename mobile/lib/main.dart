import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/providers/analysis_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/locale_provider.dart';

// localization imports
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shamba_eye/gen_l10n/app_localizations.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Give time for providers to be built
    await Future.delayed(Duration.zero);
    
    // Initialize providers (this will be called after the widget tree is built)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    // This method will be called after the first frame is rendered
    // when we can safely access the Provider context
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: _AppInitializer(),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  const _AppInitializer({super.key});

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    final authProvider = context.read<AppAuthProvider>();
    final localeProvider = context.read<LocaleProvider>();

    // Initialize locale provider with auth provider
    localeProvider.initialize(authProvider);

    // Check auth status which will load user preferences
    await authProvider.checkAuthStatus();

    // Apply user preferences after auth check
    localeProvider.applyUserPreference();

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show a simple loading screen while initializing
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Initializing...',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'ShambaEye',
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: const Color(0xFF2E7D32),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Localization config
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,

          // home
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}