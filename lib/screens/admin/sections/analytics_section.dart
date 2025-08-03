import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/api_service.dart';

class AnalyticsSection extends StatefulWidget {
  const AnalyticsSection({super.key});

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriod = 'month';

  final List<String> _periods = ['day', 'week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getAnalytics(period: _selectedPeriod);
      
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFFFFD54F),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ride Analytics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    underline: const SizedBox(),
                    items: _periods.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                      _loadAnalytics();
                    },
                  ),
                ),
              ],
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
                      onPressed: _loadAnalytics,
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
            else ...[
              // Monthly Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    Text(
                      '${_selectedPeriod.toUpperCase()} Overview',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsRow(
                      'Total Rides',
                      (_analyticsData?['summary']?['totalRides'] ?? 0).toString(),
                      FontAwesomeIcons.car,
                      Colors.blue,
                    ),
                    _buildAnalyticsRow(
                      'Completed',
                      (_analyticsData?['summary']?['completedRides'] ?? 0).toString(),
                      FontAwesomeIcons.checkCircle,
                      Colors.green,
                    ),
                    _buildAnalyticsRow(
                      'Cancelled',
                      (_analyticsData?['summary']?['cancelledRides'] ?? 0).toString(),
                      FontAwesomeIcons.timesCircle,
                      Colors.red,
                    ),
                    _buildAnalyticsRow(
                      'Revenue',
                      '₹${_analyticsData?['fareAnalytics']?['totalFare'] ?? 0}',
                      FontAwesomeIcons.indianRupeeSign,
                      Colors.orange,
                    ),
                    _buildAnalyticsRow(
                      'Active Users',
                      (_analyticsData?['summary']?['totalUsers'] ?? 0).toString(),
                      FontAwesomeIcons.users,
                      Colors.purple,
                    ),
                    _buildAnalyticsRow(
                      'Average Fare',
                      '₹${(_analyticsData?['fareAnalytics']?['avgFare'] ?? 0).toStringAsFixed(2)}',
                      FontAwesomeIcons.route,
                      Colors.teal,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Department Usage
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                      'Department Usage',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_analyticsData?['departmentAnalytics'] != null)
                      ..._buildDepartmentStats(_analyticsData!['departmentAnalytics'])
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No department data available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Additional Analytics
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                      'Performance Metrics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsRow(
                      'Pending Rides',
                      (_analyticsData?['summary']?['pendingRides'] ?? 0).toString(),
                      FontAwesomeIcons.clock,
                      Colors.indigo,
                    ),
                    _buildAnalyticsRow(
                      'Approved Rides',
                      (_analyticsData?['summary']?['approvedRides'] ?? 0).toString(),
                      FontAwesomeIcons.checkCircle,
                      Colors.green,
                    ),
                    _buildAnalyticsRow(
                      'Rejected Rides',
                      (_analyticsData?['summary']?['rejectedRides'] ?? 0).toString(),
                      FontAwesomeIcons.timesCircle,
                      Colors.red,
                    ),
                    _buildAnalyticsRow(
                      'Approval Rate',
                      '${_analyticsData?['summary']?['approvalRate'] ?? 0}%',
                      FontAwesomeIcons.percentage,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FaIcon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDepartmentStats(List<dynamic> departmentAnalytics) {
    final List<Widget> widgets = [];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.red];
    
    for (int i = 0; i < departmentAnalytics.length; i++) {
      final dept = departmentAnalytics[i];
      final department = dept['_id'] ?? 'Unknown';
      final ridesCount = dept['totalRides']?.toString() ?? '0';
      final totalFare = dept['totalFare']?.toString() ?? '0';
      final color = colors[i % colors.length];
      
      widgets.add(_buildDepartmentRow(
        department,
        '$ridesCount rides (₹$totalFare)',
        color,
      ));
    }

    if (widgets.isEmpty) {
      widgets.add(
        const Center(
          child: Text(
            'No department statistics available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildDepartmentRow(String department, String info, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(department)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              info,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
