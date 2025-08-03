# Admin Dashboard Modular Structure

## Overview
The admin dashboard has been completely restructured into a modular architecture for better maintainability and organization.

## Project Structure
```
lib/screens/admin/
├── admin_screen.dart           # Main admin screen coordinator
├── widgets/                    # Reusable UI components
│   ├── admin_drawer.dart      # Navigation drawer
│   ├── stat_card.dart         # Statistics display card
│   └── ride_card.dart         # Ride information card
└── sections/                   # Feature-specific sections
    ├── dashboard_section.dart  # Dashboard overview
    ├── analytics_section.dart  # Analytics & reports
    ├── users_section.dart      # User management
    ├── rides_section.dart      # Ride management
    ├── logs_section.dart       # Activity logs
    ├── settings_section.dart   # System settings
    └── account_section.dart    # Account management
```

## Key Features

### Main Admin Screen (`admin_screen.dart`)
- Central coordinator for all admin functionality
- Handles section navigation and state management
- Clean and minimal implementation

### Navigation (`widgets/admin_drawer.dart`)
- Responsive drawer navigation
- User profile display
- Section switching with visual feedback
- Logout functionality

### Dashboard (`sections/dashboard_section.dart`)
- Overview statistics with stat cards
- Pending ride requests
- Quick action buttons for ride approval/rejection

### Analytics (`sections/analytics_section.dart`)
- Monthly ride statistics
- Department usage breakdown
- Revenue tracking

### User Management (`sections/users_section.dart`)
- User search functionality
- User list with management options
- Add new user capability

### Ride Management (`sections/rides_section.dart`)
- All rides display with filtering
- Status-based ride organization
- Integrated ride approval/rejection

### Activity Logs (`sections/logs_section.dart`)
- Real-time activity tracking
- User action history
- System event monitoring

### Settings (`sections/settings_section.dart`)
- App configuration options
- Ride-specific settings
- Danger zone for data management

### Account Management (`sections/account_section.dart`)
- Admin profile management
- Account information display
- Security settings (2FA, password change)
- Account actions and data management

## Benefits of Modular Architecture

1. **Maintainability**: Each section is isolated and can be modified independently
2. **Reusability**: Common widgets like StatCard and RideCard can be reused
3. **Scalability**: New sections can be easily added without affecting existing code
4. **Testing**: Individual components can be unit tested separately
5. **Team Development**: Multiple developers can work on different sections simultaneously
6. **Code Organization**: Clear separation of concerns and responsibilities

## Usage
Import the main AdminScreen and use it in your navigation:
```dart
import 'package:your_app/screens/admin/admin_screen.dart';

// In your route configuration
'/admin': (context) => const AdminScreen(),
```

## Dependencies
- `provider`: State management
- `font_awesome_flutter`: Icons
- Custom providers: `AuthProvider`, `RideProvider`
