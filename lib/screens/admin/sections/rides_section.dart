import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../providers/ride_provider.dart';
import '../../../models/ride.dart';
import '../widgets/ride_card.dart';

class RidesSection extends StatefulWidget {
  const RidesSection({super.key});

  @override
  State<RidesSection> createState() => _RidesSectionState();
}

class _RidesSectionState extends State<RidesSection> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load rides when section is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().getAllRides();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<Ride> _filterRides(List<Ride> rides) {
    List<Ride> filteredRides = rides;

    // Filter by status
    if (_selectedFilter != 'all') {
      filteredRides = rides.where((ride) {
        final status = ride.status.toLowerCase();
        switch (_selectedFilter) {
          case 'pending':
            return status == 'pending' || status == 'requested';
          case 'completed':
            return status == 'completed';
          case 'cancelled':
            return status == 'cancelled' || status == 'rejected';
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredRides = filteredRides.where((ride) {
        final pickup = ride.pickup.address.toLowerCase();
        final dropoff = ride.drop.address.toLowerCase();
        final passenger = '${ride.userId?.firstName ?? ''} ${ride.userId?.lastName ?? ''}'.toLowerCase();
        final rideId = ride.id?.toLowerCase() ?? '';
        
        return pickup.contains(_searchQuery) ||
               dropoff.contains(_searchQuery) ||
               passenger.contains(_searchQuery) ||
               rideId.contains(_searchQuery);
      }).toList();
    }

    return filteredRides;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        final allRides = rideProvider.adminRides;
        final filteredRides = _filterRides(allRides);
        
        // Debug: Print the rides data
        print('🚗 RidesSection Debug:');
        print('  - Total admin rides: ${allRides.length}');
        print('  - Filtered rides: ${filteredRides.length}');
        print('  - Is loading: ${rideProvider.isLoading}');
        print('  - Error: ${rideProvider.error}');
        if (allRides.isNotEmpty) {
          print('  - First ride status: ${allRides.first.status}');
          print('  - First ride pickup: ${allRides.first.pickup.address}');
        }
        
        return RefreshIndicator(
          onRefresh: () => rideProvider.getAllRides(),
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
                      'All Rides',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          '${filteredRides.length} rides',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () => rideProvider.getAllRides(),
                          icon: rideProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          tooltip: 'Refresh rides',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.magnifyingGlass, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search rides by location, passenger, or ID...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.clear, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Filter Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildFilterTab('All', 'all')),
                      Expanded(child: _buildFilterTab('Pending', 'pending')),
                      Expanded(child: _buildFilterTab('Completed', 'completed')),
                      Expanded(child: _buildFilterTab('Cancelled', 'cancelled')),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Loading indicator
                if (rideProvider.isLoading && allRides.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                      ),
                    ),
                  )
                else if (filteredRides.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          FaIcon(
                            _searchQuery.isNotEmpty 
                                ? FontAwesomeIcons.magnifyingGlass 
                                : FontAwesomeIcons.car,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty 
                                ? 'No rides found matching your search'
                                : 'No rides found',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              child: const Text('Clear search'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  // Rides List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRides.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RideCard(ride: filteredRides[index]),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(String title, String value) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
