import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => n['isRead'] != true).length;

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

  Future<void> loadNotifications() async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.getNotifications();

      if (response['success'] == true) {
        _notifications = response['data'] ?? [];
        notifyListeners();
      } else {
        setError(response['message'] ?? 'Failed to load notifications');
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.markNotificationAsRead(notificationId);

      if (response['success'] == true) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n['_id'] == notificationId);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
          notifyListeners();
        }
        return true;
      } else {
        setError(response['message'] ?? 'Failed to mark notification as read');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await ApiService.markAllNotificationsAsRead();

      if (response['success'] == true) {
        // Update all local notifications
        for (var notification in _notifications) {
          notification['isRead'] = true;
        }
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Failed to mark all notifications as read');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    }
  }

  // Add notification locally (for real-time updates)
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n['_id'] == notificationId);
    notifyListeners();
  }
}
