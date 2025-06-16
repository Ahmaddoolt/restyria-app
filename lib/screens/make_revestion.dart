import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';

class ReservationRequestPage extends StatefulWidget {
  final String? restaurantId;
  final String restaurantName;

  const ReservationRequestPage({
    required this.restaurantId,
    required this.restaurantName,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ReservationRequestPageState createState() => _ReservationRequestPageState();
}

class _ReservationRequestPageState extends State<ReservationRequestPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _userEmail;
  String? selectedDay;
  String? selectedTimeSlot;
  List<String> availableTimeSlots = [];

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await _secureStorage.read(key: 'email');
    setState(() {
      _userEmail = email;
    });
  }

  Future<void> sendReservationRequest() async {
    if (selectedDay == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a day and time slot'.tr)),
      );
      return;
    }

    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _personsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields'.tr)),
      );
      return;
    }

    final reservationData = {
      'restaurantId': widget.restaurantId,
      'restaurantName': widget.restaurantName,
      'userName': _nameController.text,
      'userEmail': _userEmail,
      'phoneNumber': _phoneController.text,
      'numberOfPersons': _personsController.text,
      'day': selectedDay,
      'timeSlot': selectedTimeSlot,
      'message': _messageController.text,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .add(reservationData);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation request sent successfully'.tr)),
      );

      setState(() {
        _nameController.clear();
        _phoneController.clear();
        _personsController.clear();
        _messageController.clear();
        selectedDay = null;
        selectedTimeSlot = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reservation request: $e')),
      );
    }
  }

  Future<void> fetchTimeSlots(String day) async {
    try {
      DocumentSnapshot scheduleSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('schedule')
          .doc(day)
          .get();

      if (scheduleSnapshot.exists) {
        Map<String, dynamic> data =
            scheduleSnapshot.data() as Map<String, dynamic>;

        // Filter only time slots that are true
        List<String> filteredSlots = data.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList();

        // Sort by time order (10-11, 11-12, etc.)
        filteredSlots.sort((a, b) {
          int startA = int.parse(a.split('-')[0]);
          int startB = int.parse(b.split('-')[0]);
          return startA.compareTo(startB);
        });

        setState(() {
          availableTimeSlots = filteredSlots;
          selectedTimeSlot = null; // Reset selection
        });
      }
    } catch (e) {
      // print('Error fetching schedule: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Reservation Request'.tr),
        backgroundColor:
            mainColor, // Adjust the color for a more appealing look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.restaurantName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // User name input with an icon
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: accentColor),
                  labelText: 'Your Name'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Phone number input with an icon
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: accentColor),
                  labelText: 'Phone Number'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Number of persons input with an icon
              TextField(
                controller: _personsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.people, color: accentColor),
                  labelText: 'Number of Persons'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Day selection with icon
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select a day'.tr),
                value: selectedDay,
                onChanged: (newDay) {
                  setState(() {
                    selectedDay = newDay;
                    availableTimeSlots = []; // Clear previous slots
                  });
                  if (newDay != null) fetchTimeSlots(newDay);
                },
                items: daysOfWeek.map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select a time slot'.tr),
                value: selectedTimeSlot,
                onChanged: (newTimeSlot) {
                  setState(() {
                    selectedTimeSlot = newTimeSlot;
                  });
                },
                items: availableTimeSlots.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Additional message input with icon
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.message, color: accentColor),
                  labelText: 'Additional Message (Optional)'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Submit button with styling
              Center(
                child: ElevatedButton(
                  onPressed: sendReservationRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor, // Button color
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                  ),
                  child: Text(
                    'Send Reservation Request'.tr,
                    style: TextStyle(
                        fontSize: 16,
                        color: mainColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
