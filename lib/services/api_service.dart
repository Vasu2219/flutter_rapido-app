import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://rapido-backend-api.onrender.com/api';
  
  // Debug printing disabled for production
  static void _debugPrint(String message) {
    // No logging in production
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  static Future<Map<String, String>> getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (requireAuth) {
      final token = await getToken();
      _debugPrint('Token retrieved: ${token != null ? 'EXISTS (${token.substring(0, 20)}...)' : 'NULL'}');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        _debugPrint('Authorization header added');
      } else {
        _debugPrint('❌ No token available for authenticated request');
      }
    }
    
    return headers;
  }
  
  // Authentication endpoints
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String employeeId,
    required String department,
    String role = 'user',
  }) async {
    _debugPrint('Attempting to register user: $email');
    _debugPrint('Register URL: $baseUrl/auth/register');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await getHeaders(),
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'employeeId': employeeId,
          'department': department,
          'role': role,
        }),
      );
      
      _debugPrint('Register response status: ${response.statusCode}');
      _debugPrint('Register response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _debugPrint('✅ Registration successful!');
      } else {
        _debugPrint('❌ Registration failed with status: ${response.statusCode}');
      }
      
      return responseData;
    } catch (e) {
      _debugPrint('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _debugPrint('Attempting to login with email: $email');
    _debugPrint('Login URL: $baseUrl/auth/login');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      _debugPrint('Login response status: ${response.statusCode}');
      _debugPrint('Login response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _debugPrint('✅ Login successful!');
      } else {
        _debugPrint('❌ Login failed with status: ${response.statusCode}');
      }
      
      return responseData;
    } catch (e) {
      _debugPrint('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> getProfile() async {
    _debugPrint('Getting user profile');
    
    try {
      final headers = await getHeaders(requireAuth: true);
      _debugPrint('Profile request headers: $headers');
      _debugPrint('Profile request URL: $baseUrl/auth/me');
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );
      
      _debugPrint('Profile response status: ${response.statusCode}');
      _debugPrint('Profile response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _debugPrint('✅ Profile retrieved successfully!');
      } else if (response.statusCode == 401) {
        _debugPrint('❌ Token expired or invalid - removing token');
        await removeToken();
      } else {
        _debugPrint('❌ Profile request failed with status: ${response.statusCode}');
      }
      
      return responseData;
    } catch (e) {
      _debugPrint('❌ Profile error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? department,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phone != null) body['phone'] = phone;
    if (department != null) body['department'] = department;
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await getHeaders(requireAuth: true),
        body: json.encode(body),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Ride endpoints
  static Future<Map<String, dynamic>> createRide({
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> drop,
    required String scheduleTime,
    String? purpose,
    String? specialRequirements,
  }) async {
    _debugPrint('Creating new ride');
    _debugPrint('Pickup: ${pickup['address']}');
    _debugPrint('Drop: ${drop['address']}');
    _debugPrint('Schedule: $scheduleTime');
    
    try {
      final headers = await getHeaders(requireAuth: true);
      _debugPrint('Request headers: $headers');
      
      final requestBody = {
        'pickup': pickup,
        'drop': drop,
        'scheduleTime': scheduleTime,
        'purpose': purpose,
        'specialRequirements': specialRequirements,
      };
      _debugPrint('Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/rides'),
        headers: headers,
        body: json.encode(requestBody),
      );
      
      _debugPrint('Create ride response status: ${response.statusCode}');
      _debugPrint('Create ride response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _debugPrint('✅ Ride created successfully!');
      } else {
        _debugPrint('❌ Ride creation failed with status: ${response.statusCode}');
      }
      
      return responseData;
    } catch (e) {
      _debugPrint('❌ Create ride error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> getUserRides({
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    _debugPrint('Getting user rides');
    
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    
    final uri = Uri.parse('$baseUrl/rides').replace(queryParameters: queryParams);
    _debugPrint('Request URL: $uri');
    
    try {
      final headers = await getHeaders(requireAuth: true);
      _debugPrint('Request headers: $headers');
      
      final response = await http.get(
        uri,
        headers: headers,
      );
      
      _debugPrint('Get rides response status: ${response.statusCode}');
      _debugPrint('Get rides response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      // Add more detailed response structure debugging
      if (responseData is Map<String, dynamic>) {
        _debugPrint('Response structure:');
        _debugPrint('- success: ${responseData['success']}');
        _debugPrint('- message: ${responseData['message']}');
        if (responseData['data'] != null) {
          _debugPrint('- data type: ${responseData['data'].runtimeType}');
          if (responseData['data'] is Map<String, dynamic>) {
            final dataMap = responseData['data'] as Map<String, dynamic>;
            _debugPrint('- data keys: ${dataMap.keys.toList()}');
            if (dataMap.containsKey('rides')) {
              _debugPrint('- rides count: ${dataMap['rides']?.length ?? 'null'}');
            }
          }
        }
      }
      
      if (response.statusCode == 200) {
        _debugPrint('✅ Rides retrieved successfully!');
      } else {
        _debugPrint('❌ Get rides failed with status: ${response.statusCode}');
      }
      
      return responseData;
    } catch (e) {
      _debugPrint('❌ Get rides error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> getRide(String rideId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rides/$rideId'),
        headers: await getHeaders(requireAuth: true),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> cancelRide(String rideId, String reason) async {
    _debugPrint('Cancelling ride: $rideId');
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/rides/$rideId'),
        headers: await getHeaders(requireAuth: true),
        body: json.encode({
          'cancellationReason': reason,
        }),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Admin endpoints
  static Future<Map<String, dynamic>> getAllRides({
    String? status,
    String? department,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    _debugPrint('Getting all rides (admin)');
    
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (status != null) queryParams['status'] = status;
    if (department != null) queryParams['department'] = department;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    
    final uri = Uri.parse('$baseUrl/admin/rides').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Admin rides response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Admin rides error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> approveRide(String rideId) async {
    _debugPrint('Approving ride: $rideId');
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/rides/$rideId/approve'),
        headers: await getHeaders(requireAuth: true),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> rejectRide(String rideId, String reason) async {
    _debugPrint('Rejecting ride: $rideId');
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/rides/$rideId/reject'),
        headers: await getHeaders(requireAuth: true),
        body: json.encode({
          'reason': reason,
        }),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Analytics endpoints
  static Future<Map<String, dynamic>> getAnalytics({
    String? period,
    String? department,
  }) async {
    _debugPrint('Getting analytics data');
    
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;
    if (department != null) queryParams['department'] = department;
    
    final uri = Uri.parse('$baseUrl/admin/analytics').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Analytics response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Analytics error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Users management endpoints
  static Future<Map<String, dynamic>> getAllUsers({
    String? department,
    String? role,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    _debugPrint('Getting all users (admin)');
    
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (department != null) queryParams['department'] = department;
    if (role != null) queryParams['role'] = role;
    if (search != null) queryParams['search'] = search;
    
    final uri = Uri.parse('$baseUrl/users').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Users response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Users error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String employeeId,
    required String department,
    String role = 'user',
  }) async {
    _debugPrint('Creating new user (admin): $email');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: await getHeaders(requireAuth: true),
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'employeeId': employeeId,
          'department': department,
          'role': role,
        }),
      );
      
      _debugPrint('Create user response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Create user error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    _debugPrint('Updating user: $userId');
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await getHeaders(requireAuth: true),
        body: json.encode(userData),
      );
      
      _debugPrint('Update user response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Update user error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    _debugPrint('Deleting user: $userId');
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Delete user response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Delete user error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Recent activity endpoint
  static Future<Map<String, dynamic>> getRecentActivity({int limit = 10}) async {
    _debugPrint('Getting recent activity');
    
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    
    final uri = Uri.parse('$baseUrl/admin/recent-activity').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Recent activity response status: ${response.statusCode}');
      final result = json.decode(response.body);
      
      // Ensure the data field is always a list
      if (result['success'] == true && result['data'] != null) {
        if (result['data'] is! List) {
          result['data'] = [];
        }
      }
      
      return result;
    } catch (e) {
      _debugPrint('❌ Recent activity error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Notification endpoints
  static Future<Map<String, dynamic>> getNotifications({int limit = 20}) async {
    _debugPrint('Getting notifications');
    
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    
    final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Notifications response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Notifications error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': [],
      };
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    _debugPrint('Marking notification as read: $notificationId');
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Mark notification read response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Mark notification read error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    _debugPrint('Marking all notifications as read');
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: await getHeaders(requireAuth: true),
      );
      
      _debugPrint('Mark all notifications read response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Mark all notifications read error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    _debugPrint('Sending notification to user: $userId');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/send'),
        headers: await getHeaders(requireAuth: true),
        body: json.encode({
          'userId': userId,
          'type': type,
          'title': title,
          'message': message,
          'data': data,
        }),
      );
      
      _debugPrint('Send notification response status: ${response.statusCode}');
      return json.decode(response.body);
    } catch (e) {
      _debugPrint('❌ Send notification error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Test connection
  static Future<bool> testConnection() async {
    _debugPrint('Testing API connection...');
    _debugPrint('Base URL: $baseUrl');
    
    try {
      final response = await http.get(
        Uri.parse('https://rapido-backend-api.onrender.com/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      _debugPrint('Health check status: ${response.statusCode}');
      _debugPrint('Health check response: ${response.body}');
      
      if (response.statusCode == 200) {
        _debugPrint('✅ API connection successful!');
        return true;
      } else {
        _debugPrint('❌ API connection failed');
        return false;
      }
    } catch (e) {
      _debugPrint('❌ API connection error: $e');
      return false;
    }
  }

  // Validate current token
  static Future<bool> validateToken() async {
    _debugPrint('Validating current token...');
    
    final token = await getToken();
    if (token == null) {
      _debugPrint('❌ No token found');
      return false;
    }
    
    try {
      final response = await getProfile();
      return response['success'] == true;
    } catch (e) {
      _debugPrint('❌ Token validation error: $e');
      return false;
    }
  }
}
