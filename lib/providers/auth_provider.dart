import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.login(email: email, password: password);
      
      if (response['success'] == true) {
        final authResponse = AuthResponse.fromJson(response);
        _user = authResponse.user;
        _token = authResponse.token;
        
        if (_token != null) {
          await ApiService.saveToken(_token!);
        }
        
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String employeeId,
    required String department,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        employeeId: employeeId,
        department: department,
      );
      
      if (response['success'] == true) {
        // Auto-login after successful registration
        return await login(email, password);
      } else {
        setError(response['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadUserFromStorage() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        _token = token;
        final isValid = await getUserProfile();
        if (!isValid) {
          await logout();
        } else {
          notifyListeners();
        }
      }
    } catch (e) {
      await logout();
    }
  }

  Future<bool> getUserProfile() async {
    try {
      final response = await ApiService.getProfile();
      
      if (response['success'] == true && response['data'] != null) {
        // The API returns data nested in 'user' object
        final userData = response['data']['user'];
        _user = User.fromJson(userData);
        
        notifyListeners();
        return true;
      } else {
        if (response['message']?.contains('token') == true || 
            response['message']?.contains('unauthorized') == true ||
            response['message']?.contains('expired') == true) {
          await logout();
        }
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? department,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        department: department,
      );
      
      if (response['success'] == true) {
        await getUserProfile(); // Refresh user data
        return true;
      } else {
        setError(response['message'] ?? 'Update failed');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await ApiService.removeToken();
    notifyListeners();
  }

  // Helper method to check if user is truly authenticated
  bool get isReallyAuthenticated {
    final hasUser = _user != null;
    final hasToken = _token != null;
    return hasUser && hasToken;
  }

  // Validate authentication with token check
  Future<bool> validateAuthentication() async {
    // First check if we have a stored token
    final storedToken = await ApiService.getToken();
    if (storedToken == null) {
      await logout();
      return false;
    }
    
    // Set the token if it's not already set
    if (_token == null) {
      _token = storedToken;
    }
    
    // Check if we have basic authentication data
    if (_user == null) {
      final profileSuccess = await getUserProfile();
      if (!profileSuccess) {
        return false;
      }
    }
    
    try {
      // Validate token by making an API call
      final response = await ApiService.getProfile();
      
      if (response['success'] == true) {
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }
}
