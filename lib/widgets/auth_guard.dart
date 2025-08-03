import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool requireAdmin;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAdmin = false,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isChecking = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('🔐 AuthGuard: Checking authentication...');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Validate authentication
    final isValid = await authProvider.validateAuthentication();
    
    if (!isValid || !authProvider.isAuthenticated) {
      print('🔐 AuthGuard: User not authenticated');
      setState(() {
        _isChecking = false;
        _isAuthorized = false;
      });
      
      // Redirect to login after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return;
    }
    
    // Check admin requirement
    if (widget.requireAdmin && authProvider.user?.role != 'admin') {
      print('🔐 AuthGuard: Admin access required but user is not admin');
      setState(() {
        _isChecking = false;
        _isAuthorized = false;
      });
      
      // Show error and redirect
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Access denied. Admin privileges required.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
      return;
    }
    
    print('🔐 AuthGuard: Authentication successful');
    setState(() {
      _isChecking = false;
      _isAuthorized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFD54F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              Text(
                widget.requireAdmin 
                    ? 'Verifying admin access...' 
                    : 'Verifying authentication...',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isAuthorized) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFD54F),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.black,
              ),
              SizedBox(height: 20),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Redirecting to login...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widget.child;
  }
}
