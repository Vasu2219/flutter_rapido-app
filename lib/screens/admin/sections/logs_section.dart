import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/api_service.dart';

class LogsSection extends StatefulWidget {
  const LogsSection({super.key});

  @override
  State<LogsSection> createState() => _LogsSectionState();
}

class _LogsSectionState extends State<LogsSection> {
  List<dynamic> _logs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Since recent activity endpoint might not exist, use recent admin rides as activity
      final result = await ApiService.getAllRides(
        status: null, // Get all statuses
        limit: 20,
      );
      
      if (result['success'] == true) {
        final ridesData = result['data'];
        if (ridesData is List) {
          setState(() {
            _logs = ridesData.map((ride) => {
              'action': _getRideAction(ride['status']),
              'description': '${ride['pickupLocation']?['address'] ?? 'Unknown'} to ${ride['dropoffLocation']?['address'] ?? 'Unknown'}',
              'timestamp': ride['createdAt'] ?? ride['updatedAt'],
              'userId': ride['userId']?['_id'] ?? ride['userId'],
              'rideId': ride['_id'],
              'fare': ride['fare'],
              'status': ride['status'],
            }).toList();
          });
        } else {
          setState(() {
            _logs = [];
          });
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load activity logs';
          _logs = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _logs = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRideAction(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ride Requested';
      case 'approved':
        return 'Ride Approved';
      case 'rejected':
        return 'Ride Rejected';
      case 'in_progress':
        return 'Ride Started';
      case 'completed':
        return 'Ride Completed';
      case 'cancelled':
        return 'Ride Cancelled';
      default:
        return 'Ride Update';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadLogs,
      color: const Color(0xFFFFD54F),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity Logs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadLogs,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                  ),
                ),
              )
            else if (_logs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clockRotateLeft,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No activity logs found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return _buildLogItem(_logs[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final String action = log['action'] ?? 'Unknown Action';
    final String description = log['description'] ?? '';
    final String timestamp = log['timestamp'] ?? log['createdAt'] ?? '';
    
    // Determine icon and color based on action type
    IconData icon = FontAwesomeIcons.circle;
    Color color = Colors.grey;
    
    if (action.toLowerCase().contains('approved') || action.toLowerCase().contains('completed')) {
      icon = FontAwesomeIcons.check;
      color = Colors.green;
    } else if (action.toLowerCase().contains('rejected') || action.toLowerCase().contains('cancelled')) {
      icon = FontAwesomeIcons.xmark;
      color = Colors.red;
    } else if (action.toLowerCase().contains('created') || action.toLowerCase().contains('registered')) {
      icon = FontAwesomeIcons.plus;
      color = Colors.blue;
    } else if (action.toLowerCase().contains('updated') || action.toLowerCase().contains('modified')) {
      icon = FontAwesomeIcons.edit;
      color = Colors.orange;
    } else if (action.toLowerCase().contains('deleted')) {
      icon = FontAwesomeIcons.trash;
      color = Colors.red;
    } else if (action.toLowerCase().contains('login')) {
      icon = FontAwesomeIcons.arrowRightToBracket;
      color = Colors.green;
    } else if (action.toLowerCase().contains('logout')) {
      icon = FontAwesomeIcons.arrowRightFromBracket;
      color = Colors.grey;
    }

    // Format timestamp
    String timeAgo = _formatTimeAgo(timestamp);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: FaIcon(icon, color: color, size: 16),
        ),
        title: Text(
          action,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) Text(description),
            const SizedBox(height: 2),
            Text(
              timeAgo,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        isThreeLine: description.isNotEmpty,
        onTap: () => _showLogDetails(log),
      ),
    );
  }

  String _formatTimeAgo(String timestamp) {
    if (timestamp.isEmpty) return 'Unknown time';
    
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final Duration difference = DateTime.now().difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log['action'] ?? 'Activity Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (log['description']?.isNotEmpty == true) ...[
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(log['description']),
                const SizedBox(height: 12),
              ],
              if (log['userId']?.isNotEmpty == true) ...[
                const Text('User ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(log['userId']),
                const SizedBox(height: 12),
              ],
              if (log['adminId']?.isNotEmpty == true) ...[
                const Text('Admin ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(log['adminId']),
                const SizedBox(height: 12),
              ],
              if (log['timestamp']?.isNotEmpty == true || log['createdAt']?.isNotEmpty == true) ...[
                const Text('Timestamp:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(log['timestamp'] ?? log['createdAt'] ?? ''),
                const SizedBox(height: 12),
              ],
              if (log['metadata'] != null) ...[
                const Text('Additional Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(log['metadata'].toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
