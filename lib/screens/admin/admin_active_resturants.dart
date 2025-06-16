import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gustoro/screens/home/home_screen.dart';
import 'package:gustoro/shared/app_colors.dart';
import '../home/detail_resturant.dart';

class AdmmiActiveResturant extends StatefulWidget {
  const AdmmiActiveResturant({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdmmiActiveResturantState createState() => _AdmmiActiveResturantState();
}

class _AdmmiActiveResturantState extends State<AdmmiActiveResturant> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Toggle `isActive` status
  void _toggleRestaurantStatus(
      String docId, bool currentStatus, String ownerRes) async {
    await _firestore.collection('restaurants').doc(docId).update({
      'isActive': !currentStatus,
    });

    if (currentStatus == true) {
      await _firestore.collection('messages').add({
        'message': "Your Resturant has been Active.",
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': ownerRes,
      });
    } else if (currentStatus == false) {
      await _firestore.collection('messages').add({
        'message': "Your Resturant has been Active.",
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': ownerRes,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Active Resturants"),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No restaurants found"));
          }

          var restaurants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              var restaurant = restaurants[index];
              var data = restaurant.data() as Map<String, dynamic>;
              String name = data['name'] ?? 'Unnamed';
              bool isActive = data['isActive'] ?? false;
              String ownerEmail = data['emailAdmin'];
              return ListTile(
                title: Text(name),
                subtitle: Text("Active: ${isActive ? 'Yes' : 'No'}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Navigate to Restaurant Detail Page
                    IconButton(
                      icon: Icon(Icons.info_outline, color: accentColor),
                      tooltip: "View Details",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailPage(
                              restaurant: data,
                              id: restaurant.id,
                            ),
                          ),
                        );
                      },
                    ),
                    // Toggle Active Status
                    Switch(
                      value: isActive,
                      onChanged: (newValue) {
                        _toggleRestaurantStatus(
                            restaurant.id, isActive, ownerEmail);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
