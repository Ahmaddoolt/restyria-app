import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';
import 'admin/accept_user_reverstion.dart';

class RestaurantSchedulePage extends StatefulWidget {
  final String? restaurantId;

  const RestaurantSchedulePage({required this.restaurantId, Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantSchedulePageState createState() => _RestaurantSchedulePageState();
}

class _RestaurantSchedulePageState extends State<RestaurantSchedulePage> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> timeSlots = [
    '10-11',
    '11-12',
    '12-13',
    '13-14',
    '14-15',
    '15-16',
    '16-17',
    '17-18',
    '18-19',
    '19-20',
    '20-21',
    '21-22',
    '22-23',
    '23-24'
  ];

  Map<String, Map<String, bool>> _getDefaultSchedule() {
    Map<String, Map<String, bool>> schedule = {};
    for (var day in daysOfWeek) {
      schedule[day] = {};
      for (var slot in timeSlots) {
        schedule[day]![slot] = true; // Default to "Available"
      }
    }
    return schedule;
  }

  Future<void> _initializeScheduleIfNeeded() async {
    final scheduleCollection = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('schedule');

    final snapshot = await scheduleCollection.limit(1).get();
    if (snapshot.docs.isEmpty) {
      final defaultSchedule = _getDefaultSchedule();
      for (var day in defaultSchedule.keys) {
        await scheduleCollection.doc(day).set(defaultSchedule[day]!);
      }
    }
  }

  Stream<Map<String, bool>> getSchedule(String day) {
    return FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('schedule')
        .doc(day)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data
            .map((key, value) => MapEntry(key, value is bool ? value : true));
      }
      return {for (var slot in timeSlots) slot: true};
    });
  }

  Future<void> toggleSlotAvailability(
      {required String day, required String timeSlot}) async {
    final docRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('schedule')
        .doc(day);

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final currentData = docSnapshot.data() as Map<String, dynamic>;
      final currentStatus = currentData[timeSlot] as bool? ?? false;
      await docRef.update({timeSlot: !currentStatus});
    } else {
      await docRef.set({timeSlot: true}, SetOptions(merge: true));
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeScheduleIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReservationsPage(restaurantId: widget.restaurantId),
                ),
              );
            },
            icon: const Icon(Icons.book),
          )
        ],
        backgroundColor: mainColor,
        centerTitle: true,
        title: Text("Restaurant Schedule".tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Table(
                border: TableBorder.all(color: Colors.grey),
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(
                          child: Text(
                            'Time Slots'.tr,
                            style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: isWideScreen ? 10 : 10),
                          ),
                        ),
                      ),
                      ...daysOfWeek.map(
                        (day) => TableCell(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: isWideScreen ? 10 : 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var slot in timeSlots)
                    TableRow(
                      children: [
                        TableCell(
                          child: Center(
                            child: Text(
                              slot,
                              style:
                                  TextStyle(fontSize: isWideScreen ? 16 : 14),
                            ),
                          ),
                        ),
                        for (var day in daysOfWeek)
                          StreamBuilder<Map<String, bool>>(
                            stream: getSchedule(day),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData) {
                                return const Center(
                                    child: Text('No data available.'));
                              }

                              final availability = snapshot.data!;
                              final isAvailable = availability[slot] ?? true;
                              return TableCell(
                                child: GestureDetector(
                                  onTap: () => toggleSlotAvailability(
                                      day: day, timeSlot: slot),
                                  child: Container(
                                    height: 50,
                                    color:
                                        isAvailable ? Colors.green : Colors.red,
                                    child: Center(
                                      child: Icon(
                                        isAvailable ? Icons.check : Icons.dangerous,
                                       
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
