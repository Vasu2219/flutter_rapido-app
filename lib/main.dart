import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ride_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/lottie_test_screen.dart';
import 'widgets/auth_guard.dart';
import 'config/production_config.dart';

void main() {
  // Initialize production configuration
  ProductionConfig.initializeProduction();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
      ],
      child: MaterialApp(
        title: 'Rapido Corporate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          primaryColor: const Color(0xFFFFD54F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFD54F),
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Color(0xFFFFD54F),
            foregroundColor: Colors.black,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFD54F), width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const AuthGuard(child: HomeScreen()));
            case '/admin':
              return MaterialPageRoute(builder: (_) => const AuthGuard(child: AdminScreen(), requireAdmin: true));
            case '/settings':
              return MaterialPageRoute(builder: (_) => const AuthGuard(child: SettingsScreen()));
            case '/notifications':
              return MaterialPageRoute(builder: (_) => const AuthGuard(child: NotificationScreen()));
            case '/lottie-test':
              return MaterialPageRoute(builder: (_) => const LottieTestScreen());
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },
      ),
    );
  }
}
