import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  void _initializeApp() async {
    try {
      _updateStatus('Testing API connection...');
      
      // Test API connection first
      final isConnected = await ApiService.testConnection();
      
      if (isConnected) {
        _updateStatus('✅ Connected to backend!');
      } else {
        _updateStatus('❌ Backend connection failed');
      }
      
      await Future.delayed(const Duration(seconds: 1));
      
      _updateStatus('Loading user data...');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Try to load user from stored token
      await authProvider.loadUserFromStorage();
      
      // Wait for a minimum of 2 seconds for splash effect
      await Future.delayed(const Duration(seconds: 1));
      
      // Enhanced authentication check
      print('🔐 SplashScreen: Checking authentication status...');
      print('🔐 SplashScreen: User exists: ${authProvider.user != null}');
      print('🔐 SplashScreen: Token exists: ${authProvider.token != null}');
      print('🔐 SplashScreen: isAuthenticated: ${authProvider.isAuthenticated}');
      
      if (mounted) {
        // Double-check authentication with token validation
        final hasValidToken = await authProvider.validateAuthentication();
        print('🔐 SplashScreen: Valid token: $hasValidToken');
        
        if (hasValidToken && authProvider.isAuthenticated) {
          _updateStatus('Welcome back!');
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Check if user is admin
          if (authProvider.user?.role == 'admin') {
            print('🔐 SplashScreen: Redirecting to admin panel');
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            print('🔐 SplashScreen: Redirecting to home');
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          print('🔐 SplashScreen: User not authenticated, redirecting to login');
          _updateStatus('Please sign in');
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Clear any invalid authentication data
          await authProvider.logout();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      _updateStatus('❌ Initialization failed');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD54F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(75),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Rapido',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // App title
            const Text(
              'Corporate Rides',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            
            // Tagline
            const Text(
              'Made for India',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const Text(
              '❤️ Crafted in Bengaluru',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 50),
            
            // Loading indicator
            const SpinKitFadingCircle(
              color: Colors.black,
              size: 50.0,
            ),
            const SizedBox(height: 20),
            
            // Status message
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
