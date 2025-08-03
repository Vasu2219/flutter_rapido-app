import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ride.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _purposeController = TextEditingController();
  final _specialRequirementsController = TextEditingController();
  
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      print('🔐 BookRide: Checking authentication...');
      print('🔐 BookRide: Is authenticated: ${authProvider.isAuthenticated}');
      print('🔐 BookRide: User: ${authProvider.user?.firstName}');
      print('🔐 BookRide: Token exists: ${authProvider.token != null}');
      
      if (!authProvider.isAuthenticated) {
        print('🔐 BookRide: User not authenticated, redirecting to login');
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('Authentication Required'),
                ],
              ),
              content: const Text(
                'You need to login first to book rides. Please login to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Login'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _purposeController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Book a Ride',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFFD54F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.car,
                        color: Color(0xFFFFD54F),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Corporate Ride Booking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Book your official rides with ease',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Pickup Location
              _buildLocationField(
                controller: _pickupController,
                title: 'Pickup Location',
                icon: FontAwesomeIcons.locationDot,
                iconColor: Colors.green,
                hint: 'Enter pickup address',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Drop Location
              _buildLocationField(
                controller: _dropController,
                title: 'Drop Location',
                icon: FontAwesomeIcons.locationDot,
                iconColor: Colors.red,
                hint: 'Enter destination address',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter drop location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Schedule Time
              _buildDateTimeField(),
              
              const SizedBox(height: 20),
              
              // Purpose
              _buildTextField(
                controller: _purposeController,
                title: 'Purpose (Optional)',
                icon: FontAwesomeIcons.briefcase,
                hint: 'e.g., Client meeting, Airport pickup',
              ),
              
              const SizedBox(height: 20),
              
              // Special Requirements
              _buildTextField(
                controller: _specialRequirementsController,
                title: 'Special Requirements (Optional)',
                icon: FontAwesomeIcons.noteSticky,
                hint: 'e.g., AC car, Large luggage space',
                maxLines: 3,
              ),
              
              const SizedBox(height: 40),
              
              // Book Ride Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.car, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Book Ride',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFD54F), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(
                icon,
                color: Colors.grey,
                size: 16,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFD54F), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.calendar,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    _selectedDateTime != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime!)
                        : 'Select date and time',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDateTime != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                const FaIcon(
                  FontAwesomeIcons.chevronDown,
                  color: Colors.grey,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFD54F),
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFFD54F),
                onPrimary: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _bookRide() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a schedule time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Double-check authentication before proceeding
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      print('🔐 BookRide: Authentication lost, redirecting to login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please login first to book rides'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      
      // Create Location objects
      final pickup = Location(
        address: _pickupController.text.trim(),
        latitude: 12.9716, // Default latitude (can be enhanced with GPS)
        longitude: 77.5946, // Default longitude
        landmark: 'Office Location',
      );

      final drop = Location(
        address: _dropController.text.trim(),
        latitude: 13.1986, // Default latitude
        longitude: 77.7066, // Default longitude
        landmark: 'Destination',
      );

      print('🚗 Booking ride from ${pickup.address} to ${drop.address}');
      print('🚗 User: ${authProvider.user?.firstName} (${authProvider.user?.email})');

      final success = await rideProvider.createRide(
        pickup: pickup,
        drop: drop,
        scheduleTime: _selectedDateTime!,
        purpose: _purposeController.text.trim().isNotEmpty 
            ? _purposeController.text.trim() 
            : null,
        specialRequirements: _specialRequirementsController.text.trim().isNotEmpty 
            ? _specialRequirementsController.text.trim() 
            : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ride booked successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Clear form
        _pickupController.clear();
        _dropController.clear();
        _purposeController.clear();
        _specialRequirementsController.clear();
        setState(() {
          _selectedDateTime = null;
        });
        
        // Navigate back or to rides screen
        Navigator.pop(context);
      } else if (mounted) {
        final errorMessage = rideProvider.error ?? 'Unknown error';
        
        // Check if error is authentication-related
        if (errorMessage.toLowerCase().contains('token') || 
            errorMessage.toLowerCase().contains('unauthorized') ||
            errorMessage.toLowerCase().contains('access denied')) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Session expired. Please login again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
          
          await authProvider.logout();
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to book ride: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Booking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error booking ride: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
