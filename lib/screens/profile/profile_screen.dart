import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFFD54F),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFFFD54F),
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.department,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Employee ID: ${user.employeeId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Profile Information
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoRow(
                        FontAwesomeIcons.envelope,
                        'Email',
                        user.email,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoRow(
                        FontAwesomeIcons.phone,
                        'Phone',
                        user.phone,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoRow(
                        FontAwesomeIcons.building,
                        'Department',
                        user.department,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoRow(
                        FontAwesomeIcons.idCard,
                        'Employee ID',
                        user.employeeId,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Account Actions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.gear,
                          color: Colors.grey,
                        ),
                        title: const Text('Settings'),
                        trailing: const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          // TODO: Navigate to settings
                        },
                      ),
                      
                      const Divider(),
                      
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.circleQuestion,
                          color: Colors.grey,
                        ),
                        title: const Text('Help & Support'),
                        trailing: const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                      
                      const Divider(),
                      
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.rightFromBracket,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          await authProvider.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Info
                const Text(
                  '🇮🇳 Made for India',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  '❤️ Crafted in Bengaluru',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
