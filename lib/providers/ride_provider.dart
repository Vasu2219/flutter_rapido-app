import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../services/api_service.dart';

class RideProvider with ChangeNotifier {
  List<Ride> _rides = [];
  List<Ride> _adminRides = [];
  bool _isLoading = false;
  String? _error;

  List<Ride> get rides => _rides;
  List<Ride> get adminRides => _adminRides;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<bool> createRide({
    required Location pickup,
    required Location drop,
    required DateTime scheduleTime,
    String? purpose,
    String? specialRequirements,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.createRide(
        pickup: pickup.toJson(),
        drop: drop.toJson(),
        scheduleTime: scheduleTime.toIso8601String(),
        purpose: purpose,
        specialRequirements: specialRequirements,
      );

      if (response['success'] == true) {
        // Notify admin about new ride request
        await ApiService.sendNotification(
          userId: 'admin', // Send to all admins
          type: 'new_ride_request',
          title: 'New Ride Request 🚗',
          message: 'A new ride has been requested from ${pickup.address} to ${drop.address}',
          data: {
            'rideId': response['data']?['_id'],
            'pickup': pickup.address,
            'drop': drop.address,
            'scheduleTime': scheduleTime.toIso8601String(),
          },
        );
        
        await getUserRides(); // Refresh rides list
        return true;
      } else {
        setError(response['message'] ?? 'Failed to create ride');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> getUserRides({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.getUserRides(
        status: status,
        startDate: startDate,
        endDate: endDate,
        limit: 50, // Get more rides
      );

      if (response['success'] == true && response['data'] != null) {
        // Check if data contains a 'rides' array or if data itself is the array
        List<dynamic> ridesData;
        
        if (response['data'] is Map<String, dynamic>) {
          // If data is a map, look for 'rides' key
          final dataMap = response['data'] as Map<String, dynamic>;
          if (dataMap.containsKey('rides') && dataMap['rides'] is List) {
            ridesData = dataMap['rides'] as List<dynamic>;
          } else {
            // If no 'rides' key, try to get all values that might be rides
            ridesData = [];
            print('🚗 RideProvider: Data is a map but no rides array found');
          }
        } else if (response['data'] is List) {
          // If data is already a list
          ridesData = response['data'] as List<dynamic>;
        } else {
          ridesData = [];
          print('🚗 RideProvider: Data is neither a map nor a list');
        }
        
        print('🚗 RideProvider: Processing ${ridesData.length} rides');
        _rides = [];
        
        for (int i = 0; i < ridesData.length; i++) {
          try {
            print('🚗 RideProvider: Parsing ride $i: ${ridesData[i].runtimeType}');
            if (ridesData[i] is Map<String, dynamic>) {
              final rideJson = ridesData[i] as Map<String, dynamic>;
              print('🚗 RideProvider: Ride $i keys: ${rideJson.keys.toList()}');
              print('🚗 RideProvider: Pickup type: ${rideJson['pickup'].runtimeType}');
              print('🚗 RideProvider: Drop type: ${rideJson['drop'].runtimeType}');
              
              final ride = Ride.fromJson(rideJson);
              _rides.add(ride);
              print('🚗 RideProvider: Successfully parsed ride $i');
            } else {
              print('🚗 RideProvider: Ride $i is not a Map: ${ridesData[i]}');
            }
          } catch (e) {
            print('🚗 RideProvider: Error parsing ride $i: $e');
            print('🚗 RideProvider: Ride data: ${ridesData[i]}');
          }
        }
        
        print('🚗 RideProvider: Successfully parsed ${_rides.length} rides');
        notifyListeners();
      } else {
        print('🚗 RideProvider: API call failed');
        setError(response['message'] ?? 'Failed to load rides');
      }
    } catch (e) {
      print('🚗 RideProvider: Exception occurred: $e');
      setError('Network error: ${e.toString()}');
    } finally {
      setLoading(false);
      print('🚗 RideProvider: getUserRides completed');
    }
  }

  Future<bool> cancelRide(String rideId, String reason) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.cancelRide(rideId, reason);

      if (response['success'] == true) {
        await getUserRides(); // Refresh rides list
        return true;
      } else {
        setError(response['message'] ?? 'Failed to cancel ride');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Admin functions
  Future<void> getAllRides({
    String? status,
    String? department,
    String? startDate,
    String? endDate,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.getAllRides(
        status: status,
        department: department,
        startDate: startDate,
        endDate: endDate,
        limit: 50,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> ridesData = response['data']['rides'] ?? response['data'];
        _adminRides = ridesData.map((json) => Ride.fromJson(json)).toList();
        print('🚗 RideProvider: Loaded ${_adminRides.length} admin rides');
        notifyListeners();
      } else {
        setError(response['message'] ?? 'Failed to load rides');
        print('❌ RideProvider: Failed to load rides - ${response['message']}');
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> approveRide(String rideId) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.approveRide(rideId);

      if (response['success'] == true) {
        // Send notification to user
        final ride = _adminRides.firstWhere((r) => r.id == rideId, orElse: () => _adminRides.first);
        if (ride.userId?.id != null) {
          await ApiService.sendNotification(
            userId: ride.userId!.id!,
            type: 'ride_approved',
            title: 'Ride Approved! 🎉',
            message: 'Your ride request has been approved and is ready to go.',
            data: {'rideId': rideId, 'status': 'approved'},
          );
        }
        
        await getAllRides(); // Refresh admin rides list
        return true;
      } else {
        setError(response['message'] ?? 'Failed to approve ride');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> rejectRide(String rideId, String reason) async {
    try {
      setLoading(true);
      clearError();

      final response = await ApiService.rejectRide(rideId, reason);

      if (response['success'] == true) {
        // Send notification to user
        final ride = _adminRides.firstWhere((r) => r.id == rideId, orElse: () => _adminRides.first);
        if (ride.userId?.id != null) {
          await ApiService.sendNotification(
            userId: ride.userId!.id!,
            type: 'ride_rejected',
            title: 'Ride Request Update',
            message: 'Your ride request has been declined. Reason: $reason',
            data: {'rideId': rideId, 'status': 'rejected', 'reason': reason},
          );
        }
        
        await getAllRides(); // Refresh admin rides list
        return true;
      } else {
        setError(response['message'] ?? 'Failed to reject ride');
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  List<Ride> get pendingRides => _rides.where((ride) => ride.status == 'pending').toList();
  List<Ride> get approvedRides => _rides.where((ride) => ride.status == 'approved').toList();
  List<Ride> get completedRides => _rides.where((ride) => ride.status == 'completed').toList();
  List<Ride> get adminPendingRides => _adminRides.where((ride) => ride.status == 'pending').toList();
}
