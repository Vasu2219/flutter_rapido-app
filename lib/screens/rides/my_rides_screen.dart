import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/ride_provider.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  String _selectedStatusFilter = 'all';
  
  final List<Map<String, String>> _statusFilters = [
    {'value': 'all', 'label': 'All Rides'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'approved', 'label': 'Approved'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'cancelled', 'label': 'Cancelled'},
    {'value': 'rejected', 'label': 'Rejected'},
  ];

  @override
  void initState() {
    super.initState();
    print('🚗 MyRidesScreen: Initializing and loading rides');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRides();
    });
  }

  Future<void> _loadRides() async {
    print('🚗 MyRidesScreen: Loading user rides...');
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    await rideProvider.getUserRides();
    print('🚗 MyRidesScreen: Rides loaded, count: ${rideProvider.rides.length}');
    if (rideProvider.error != null) {
      print('🚗 MyRidesScreen: Error loading rides: ${rideProvider.error}');
    }
  }

  List<dynamic> _getFilteredRides(List<dynamic> rides) {
    if (_selectedStatusFilter == 'all') {
      return rides;
    }
    return rides.where((ride) => ride.status == _selectedStatusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Rides'),
        backgroundColor: const Color(0xFFFFD54F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          print('🚗 MyRidesScreen: Building UI, loading: ${rideProvider.isLoading}, rides count: ${rideProvider.rides.length}, error: ${rideProvider.error}');
          
          if (rideProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your rides...'),
                ],
              ),
            );
          }

          // Show error if there's one
          if (rideProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading rides',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rideProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRides,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredRides = _getFilteredRides(rideProvider.rides);
          print('🚗 MyRidesScreen: Filtered rides count: ${filteredRides.length}');

          return Column(
            children: [
              // Status Filter
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    const Text(
                      'Filter by Status:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedStatusFilter,
                        isExpanded: true,
                        items: _statusFilters.map((filter) {
                          return DropdownMenuItem<String>(
                            value: filter['value'],
                            child: Text(filter['label']!),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatusFilter = newValue ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Rides List
              Expanded(
                child: filteredRides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.car,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedStatusFilter == 'all' 
                                  ? 'No rides yet'
                                  : 'No ${_selectedStatusFilter} rides',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedStatusFilter == 'all'
                                  ? 'Book your first ride to get started'
                                  : 'Try changing the filter to see other rides',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loadRides,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD54F),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await rideProvider.getUserRides();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredRides.length,
                          itemBuilder: (context, index) {
                            final ride = filteredRides[index];
                            return _buildRideCard(context, ride, rideProvider);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, dynamic ride, RideProvider rideProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(ride.scheduleTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ride.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(ride.status),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(ride.status),
                        size: 16,
                        color: _getStatusColor(ride.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ride.statusDisplayName,
                        style: TextStyle(
                          color: _getStatusColor(ride.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Pickup location
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ride.pickup.address,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Drop location
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Drop',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ride.drop.address,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Purpose and additional info
            if (ride.purpose != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.clipboard,
                      size: 14,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Purpose: ${ride.purpose}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Special requirements
            if (ride.specialRequirements != null && ride.specialRequirements!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.exclamation,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Special Requirements: ${ride.specialRequirements}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Rejection or cancellation reason
            if (ride.status == 'rejected' && ride.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      size: 14,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rejection Reason: ${ride.rejectionReason}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (ride.status == 'cancelled' && ride.cancellationReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.ban,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancellation Reason: ${ride.cancellationReason}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Action buttons
            if (ride.canBeCancelled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCancelDialog(context, ride.id!);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 16,
                  ),
                  label: const Text('Cancel Ride'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return FontAwesomeIcons.clock;
      case 'approved':
        return FontAwesomeIcons.check;
      case 'completed':
        return FontAwesomeIcons.flagCheckered;
      case 'cancelled':
        return FontAwesomeIcons.ban;
      case 'rejected':
        return FontAwesomeIcons.xmark;
      default:
        return FontAwesomeIcons.question;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showCancelDialog(BuildContext context, String rideId) async {
    final reasonController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.red,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('Cancel Ride'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to cancel this ride? This action cannot be undone.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason',
                  hintText: 'Please provide a reason for cancellation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Ride'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Ride'),
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Please provide a reason for cancellation",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  return;
                }
                
                final rideProvider = Provider.of<RideProvider>(context, listen: false);
                Navigator.of(context).pop();
                
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Cancelling ride...'),
                        ],
                      ),
                    );
                  },
                );
                
                final success = await rideProvider.cancelRide(rideId, reasonController.text.trim());
                
                // Close loading dialog
                Navigator.of(context).pop();
                
                if (success) {
                  Fluttertoast.showToast(
                    msg: "Ride cancelled successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: rideProvider.error ?? "Failed to cancel ride",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
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
