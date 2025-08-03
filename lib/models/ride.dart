import 'user.dart';

class Location {
  final String address;
  final double? latitude;
  final double? longitude;
  final String? landmark;

  Location({
    required this.address,
    this.latitude,
    this.longitude,
    this.landmark,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      landmark: json['landmark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
    };
  }
}

class Driver {
  final String name;
  final String phone;
  final String vehicle;
  final double rating;

  Driver({
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.rating,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      vehicle: json['vehicle'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
      'rating': rating,
    };
  }
}

class Feedback {
  final int rating;
  final String? comment;

  Feedback({
    required this.rating,
    this.comment,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      rating: json['rating'] ?? 0,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}

class Ride {
  final String? id;
  final User? userId;
  final Location pickup;
  final Location drop;
  final DateTime scheduleTime;
  final String status;
  final double? estimatedFare;
  final double? actualFare;
  final String? purpose;
  final String? specialRequirements;
  final Driver? driver;
  final User? approvedBy;
  final DateTime? approvedAt;
  final User? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Feedback? feedback;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ride({
    this.id,
    this.userId,
    required this.pickup,
    required this.drop,
    required this.scheduleTime,
    this.status = 'pending',
    this.estimatedFare,
    this.actualFare,
    this.purpose,
    this.specialRequirements,
    this.driver,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.cancelledAt,
    this.cancellationReason,
    this.feedback,
    this.createdAt,
    this.updatedAt,
  });

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get canBeCancelled {
    return status == 'pending' || status == 'approved';
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse Location
    Location parseLocation(dynamic locationData, String fallbackAddress) {
      if (locationData == null) {
        return Location(address: fallbackAddress);
      }
      
      if (locationData is String) {
        // If it's a string (like "[object Object]"), create a default location
        if (locationData.startsWith('[object') || locationData.isEmpty) {
          return Location(address: fallbackAddress);
        }
        // If it's a valid address string, use it
        return Location(address: locationData);
      }
      
      if (locationData is Map<String, dynamic>) {
        return Location.fromJson(locationData);
      }
      
      // Fallback case
      return Location(address: fallbackAddress);
    }

    // Helper function to safely parse User
    User? parseUser(dynamic userData) {
      if (userData == null) return null;
      
      if (userData is String) {
        // If it's a string reference, we can't parse it
        return null;
      }
      
      if (userData is Map<String, dynamic>) {
        try {
          return User.fromJson(userData);
        } catch (e) {
          // Handle parsing error silently
          return null;
        }
      }
      
      return null;
    }

    // Helper function to safely parse Driver
    Driver? parseDriver(dynamic driverData) {
      if (driverData == null) return null;
      
      if (driverData is String) {
        return null;
      }
      
      if (driverData is Map<String, dynamic>) {
        try {
          return Driver.fromJson(driverData);
        } catch (e) {
          // Handle parsing error silently
          return null;
        }
      }
      
      return null;
    }

    return Ride(
      id: json['_id'] ?? json['id'],
      userId: parseUser(json['userId']),
      pickup: parseLocation(json['pickup'], 'Pickup Location'),
      drop: parseLocation(json['drop'], 'Drop Location'),
      scheduleTime: DateTime.parse(json['scheduleTime']),
      status: json['status'] ?? 'pending',
      estimatedFare: json['estimatedFare']?.toDouble(),
      actualFare: json['actualFare']?.toDouble(),
      purpose: json['purpose'],
      specialRequirements: json['specialRequirements'],
      driver: parseDriver(json['driver']),
      approvedBy: parseUser(json['approvedBy']),
      approvedAt: json['approvedAt'] != null ? DateTime.tryParse(json['approvedAt']) : null,
      rejectedBy: parseUser(json['rejectedBy']),
      rejectedAt: json['rejectedAt'] != null ? DateTime.tryParse(json['rejectedAt']) : null,
      rejectionReason: json['rejectionReason'],
      cancelledAt: json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt']) : null,
      cancellationReason: json['cancellationReason'],
      feedback: json['feedback'] != null && json['feedback'] is Map<String, dynamic> 
          ? Feedback.fromJson(json['feedback']) 
          : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId?.toJson(),
      'pickup': pickup.toJson(),
      'drop': drop.toJson(),
      'scheduleTime': scheduleTime.toIso8601String(),
      'status': status,
      'estimatedFare': estimatedFare,
      'actualFare': actualFare,
      'purpose': purpose,
      'specialRequirements': specialRequirements,
      'driver': driver?.toJson(),
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedBy': rejectedBy?.toJson(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'feedback': feedback?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
