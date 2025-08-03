import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../providers/ride_provider.dart';

class RideCard extends StatelessWidget {
  final dynamic ride;

  const RideCard({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ride.userId?.fullName ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ride.statusDisplayName).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ride.statusDisplayName,
                    style: TextStyle(
                      color: _getStatusColor(ride.statusDisplayName),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${ride.userId?.department ?? ''} • ${ride.userId?.employeeId ?? ''}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.locationDot, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(ride.pickup.address, style: const TextStyle(fontSize: 14))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.locationDot, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(ride.drop.address, style: const TextStyle(fontSize: 14))),
              ],
            ),
            if (ride.purpose != null) ...[
              const SizedBox(height: 12),
              Text('Purpose: ${ride.purpose}', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            ],
            if (ride.statusDisplayName == 'Pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (ride.id != null) {
                          final rideProvider = Provider.of<RideProvider>(context, listen: false);
                          final success = await rideProvider.approveRide(ride.id!);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success 
                                    ? '✅ Ride approved! ${ride.userId?.firstName ?? 'User'} has been notified and can proceed with the ride.'
                                    : '❌ Failed to approve ride. Please try again.'
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (ride.id != null) {
                          await _showRejectDialog(context, ride.id!);
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 16),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _showRejectDialog(BuildContext context, String rideId) async {
    final reasonController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reject Ride'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason',
              hintText: 'Enter reason for rejection',
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Reject'),
              onPressed: () async {
                if (reasonController.text.trim().isNotEmpty) {
                  final rideProvider = Provider.of<RideProvider>(context, listen: false);
                  final success = await rideProvider.rejectRide(rideId, reasonController.text.trim());
                  Navigator.of(dialogContext).pop();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success 
                            ? '🚫 Ride rejected. ${ride.userId?.firstName ?? 'User'} has been notified with the reason provided.'
                            : '❌ Failed to reject ride. Please try again.'
                        ),
                        backgroundColor: success ? Colors.orange : Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } else {
                  // Show error if no reason provided
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for rejection'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
