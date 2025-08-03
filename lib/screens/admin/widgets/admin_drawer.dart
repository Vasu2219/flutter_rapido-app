import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../providers/auth_provider.dart';

class AdminDrawer extends StatelessWidget {
  final String currentSection;
  final Function(String) onSectionChanged;

  const AdminDrawer({
    super.key,
    required this.currentSection,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD54F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: FaIcon(
                              FontAwesomeIcons.userShield,
                              color: Colors.grey[700],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.user?.firstName ?? 'Admin',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  'Administrator',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.chartLine,
                    title: 'Dashboard',
                    section: 'dashboard',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.chartBar,
                    title: 'Analytics',
                    section: 'analytics',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.users,
                    title: 'Users',
                    section: 'users',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.car,
                    title: 'All Rides',
                    section: 'rides',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.clockRotateLeft,
                    title: 'Recent Logs',
                    section: 'logs',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.gear,
                    title: 'Settings',
                    section: 'settings',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.userGear,
                    title: 'Account Details',
                    section: 'account',
                  ),
                  const Divider(height: 30),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.rightFromBracket,
                    title: 'Logout',
                    section: 'logout',
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String section,
    bool isLogout = false,
  }) {
    bool isSelected = currentSection == section && !isLogout;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: const Color(0xFFFFD54F).withOpacity(0.1),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFFFD54F) 
                : isLogout 
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(
            icon,
            size: 18,
            color: isSelected 
                ? Colors.black 
                : isLogout 
                    ? Colors.red
                    : Colors.grey[600],
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (isLogout) {
            _showLogoutDialog(context);
          } else {
            onSectionChanged(section);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                if (context.mounted) {
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
