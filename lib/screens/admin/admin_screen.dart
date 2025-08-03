import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/notification_provider.dart';
import 'widgets/admin_drawer.dart';
import 'sections/dashboard_section.dart';
import 'sections/analytics_section.dart';
import 'sections/users_section.dart';
import 'sections/rides_section.dart';
import 'sections/logs_section.dart';
import 'sections/settings_section.dart';
import 'sections/account_section.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _currentSection = 'dashboard';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 AdminScreen: Loading initial data...');
      Provider.of<RideProvider>(context, listen: false).getAllRides().then((_) {
        print('🚀 AdminScreen: getAllRides completed');
      });
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: AdminDrawer(
        currentSection: _currentSection,
        onSectionChanged: (section) {
          setState(() {
            _currentSection = section;
          });
        },
      ),
      appBar: AppBar(
        title: Text(_getSectionTitle()),
        backgroundColor: const Color(0xFFFFD54F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Consumer<RideProvider>(
            builder: (context, rideProvider, child) {
              final pendingCount = rideProvider.adminPendingRides.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () => _showPendingRidesDialog(),
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket, color: Colors.black),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: _buildCurrentSection(),
    );
  }

  String _getSectionTitle() {
    switch (_currentSection) {
      case 'dashboard': return 'Admin Dashboard';
      case 'analytics': return 'Analytics';
      case 'users': return 'Users Management';
      case 'rides': return 'All Rides';
      case 'logs': return 'Recent Logs';
      case 'settings': return 'Settings';
      case 'account': return 'Account Details';
      default: return 'Admin Dashboard';
    }
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 'dashboard': return const DashboardSection();
      case 'analytics': return const AnalyticsSection();
      case 'users': return const UsersSection();
      case 'rides': return const RidesSection();
      case 'logs': return const LogsSection();
      case 'settings': return const SettingsSection();
      case 'account': return const AccountSection();
      default: return const DashboardSection();
    }
  }

  void _showPendingRidesDialog() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final pendingRides = rideProvider.adminPendingRides;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.pending_actions, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Pending Rides (${pendingRides.length})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: pendingRides.isEmpty
              ? const Center(
                  child: Text('No pending rides'),
                )
              : ListView.builder(
                  itemCount: pendingRides.length,
                  itemBuilder: (context, index) {
                    final ride = pendingRides[index];
                    return Card(
                      child: ListTile(
                        title: Text('${ride.pickup.address} → ${ride.drop.address}'),
                        subtitle: Text('Requested by: ${ride.userId?.firstName ?? 'Unknown'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                Navigator.pop(context);
                                final success = await rideProvider.approveRide(ride.id!);
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ride approved successfully! User has been notified via notification.'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                _showRejectDialog(ride.id!);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentSection = 'rides';
              });
            },
            child: const Text('View All Rides'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String rideId) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Ride'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this ride:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final rideProvider = Provider.of<RideProvider>(context, listen: false);
                final success = await rideProvider.rejectRide(rideId, reasonController.text.trim());
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ride rejected successfully! User has been notified with the reason.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
