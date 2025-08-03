import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays vehicle Lottie animations
class VehicleAnimationWidget extends StatelessWidget {
  final VehicleType vehicleType;
  final double? width;
  final double? height;
  final bool repeat;
  final bool animate;

  const VehicleAnimationWidget({
    super.key,
    required this.vehicleType,
    this.width = 100,
    this.height = 100,
    this.repeat = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    String animationPath;
    
    switch (vehicleType) {
      case VehicleType.car:
        animationPath = 'assets/lottie/Car.json';
        break;
      case VehicleType.motorcycle:
        animationPath = 'assets/lottie/Motorcycle.json';
        break;
    }

    return Container(
      width: width,
      height: height,
      child: Lottie.asset(
        animationPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        repeat: repeat,
        animate: animate,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if animation fails to load
          return Icon(
            vehicleType == VehicleType.car 
              ? Icons.directions_car 
              : Icons.motorcycle,
            size: (width ?? 100) * 0.6,
            color: vehicleType == VehicleType.car 
              ? Colors.blue 
              : Colors.orange,
          );
        },
      ),
    );
  }
}

/// Enum for different vehicle types
enum VehicleType {
  car,
  motorcycle,
}

/// Extension to get display names for vehicle types
extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.motorcycle:
        return 'Motorcycle';
    }
  }
  
  String get animationPath {
    switch (this) {
      case VehicleType.car:
        return 'assets/lottie/Car.json';
      case VehicleType.motorcycle:
        return 'assets/lottie/Motorcycle.json';
    }
  }
}
