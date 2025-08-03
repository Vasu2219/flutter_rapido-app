import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../providers/ride_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/ride_card.dart';
import '../../../services/api_service.dart';

class DashboardSection extends StatefulWidget {
  const DashboardSection({super.key});

  @override
  State<DashboardSection> createState() => _DashboardSectionState();
}

class _DashboardSectionState extends State<DashboardSection> {
  Map<String, dynamic>? _analyticsData;
  bool _isLoadingAnalytics = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoadingAnalytics = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getAnalytics();
      if (result['success'] == true) {
        setState(() {
          _analyticsData = result['data'];
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load analytics';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoadingAnalytics = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        if (rideProvider.isLoading && _isLoadingAnalytics) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
            ),
          );
        }

        final pendingRides = rideProvider.adminPendingRides;
        final allRides = rideProvider.adminRides;
        final analytics = _analyticsData ?? {};
        final summary = analytics['summary'] ?? {};
        final fareAnalytics = analytics['fareAnalytics'] ?? {};

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _loadAnalytics(),
              rideProvider.getAllRides(),
            ]);
          },
          color: const Color(0xFFFFD54F),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Error message if analytics failed
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
                        Icon(Icons.warning, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadAnalytics,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),

                // Stats Cards Row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Pending Rides',
                        value: (summary['pendingRides'] ?? pendingRides.length).toString(),
                        icon: FontAwesomeIcons.clock,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Rides',
                        value: (summary['totalRides'] ?? allRides.length).toString(),
                        icon: FontAwesomeIcons.car,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Additional Stats
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Active Users',
                        value: (summary['totalUsers'] ?? 0).toString(),
                        icon: FontAwesomeIcons.users,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Revenue',
                        value: '₹${fareAnalytics['totalFare'] ?? 0}',
                        icon: FontAwesomeIcons.chartLine,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recent Pending Rides
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Pending Requests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (pendingRides.isNotEmpty)
                          Text(
                            'Tap approve/reject buttons to take action',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    if (pendingRides.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          // Navigate to rides section
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(color: Color(0xFFFFD54F)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (pendingRides.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.checkCircle,
                            size: 48,
                            color: Colors.green[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'All caught up!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No pending ride requests at the moment',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notification_important, color: Colors.orange.shade600),
                            const SizedBox(width: 8),
                            Text(
                              '${pendingRides.length} requests awaiting your approval',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingRides.take(5).length,
                          itemBuilder: (context, index) {
                            final ride = pendingRides[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RideCard(ride: ride),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
