import 'package:flutter/foundation.dart';

/// Production configuration for the Rapido Corporate app
class ProductionConfig {
  /// Whether debugging is enabled
  static bool get isDebugMode => kDebugMode;
  
  /// Whether logging is enabled
  static bool get isLoggingEnabled => kDebugMode;
  
  /// Whether API logging is enabled
  static bool get isAPILoggingEnabled => kDebugMode;
  
  /// Base API URL for production
  static const String apiBaseUrl = 'https://rapido-backend-api.onrender.com/api';
  
  /// App name for production
  static const String appName = 'Rapido Corporate';
  
  /// App version
  static const String appVersion = '1.0.0';
  
  /// Initialize production settings
  static void initializeProduction() {
    if (kReleaseMode) {
      // Disable all debug output in release mode
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
  }
  
  /// Whether to show debug information in UI
  static bool get showDebugInfo => kDebugMode;
  
  /// Whether to enable detailed error messages
  static bool get enableDetailedErrors => kDebugMode;
}
