import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';

class ReservationsPage extends StatefulWidget {
  final String? restaurantId;

  const ReservationsPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _acceptReservation(String reservationId, String userEmail) async {
    try {
      await _firestore.collection('messages').add({
        'userEmail': userEmail,
        'message': 'Your reservation has been approved.',
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('reservations').doc(reservationId).delete();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Reservation approved and user notified.'.tr)),
      );
    } catch (e) {
      // print('Error approving reservation: $e');
    }
  }

  Future<void> _rejectReservation(String reservationId, String userEmail) async {
    try {
      await _firestore.collection('messages').add({
        'userEmail': userEmail,
        'message': 'Your reservation has been rejected.',
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('reservations').doc(reservationId).delete();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Reservation rejected and user notified.'.tr)),
      );
    } catch (e) {
      // print('Error rejecting reservation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title:  Text('Reservations'.tr),
        backgroundColor: mainColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('reservations')
            .where('restaurantId', isEqualTo: widget.restaurantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data!.docs;

          if (reservations.isEmpty) {
            return  Center(
              child: Text(
                'No reservations found.'.tr,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final data = reservation.data() as Map<String, dynamic>;

              return Card(
                color: mainColor2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            data['userName'] ?? 'No Name',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow(Icons.phone, 'Phone', data['phoneNumber']),
                      _buildInfoRow(Icons.people, 'Persons', data['numberOfPersons']),
                      _buildInfoRow(Icons.message, 'Message', data['message']),
                      _buildInfoRow(Icons.access_time, 'Time Slot', data['timeSlot']),
                      _buildInfoRow(Icons.calendar_today, 'Day', data['day']),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${data['status'] ?? 'Pending'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: data['status'] == 'Pending'
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, color: Colors.white),
                            label:  Text('Approve'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _acceptReservation(
                              reservation.id,
                              data['userEmail'] ?? '',
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.close, color: Colors.white),
                            label:  Text('Reject'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _rejectReservation(
                              reservation.id,
                              data['userEmail'] ?? '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ${value ?? 'N/A'}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
