import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';

import '../home/home_screen.dart';
import 'admin_deapprove_vip.dart';

class AdminVIPRequestsPage extends StatefulWidget {
  const AdminVIPRequestsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminVIPRequestsPageState createState() => _AdminVIPRequestsPageState();
}

class _AdminVIPRequestsPageState extends State<AdminVIPRequestsPage> {
  Future<void> _makeRestaurantVIP(String email) async {
    try {
      // Search for the restaurant document where the email matches
      QuerySnapshot restaurantQuery = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('emailAdmin', isEqualTo: email)
          .get();

      if (restaurantQuery.docs.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant not found for email: $email')),
        );
        return;
      }

      // Update the isVip field to true for the matched restaurant document
      DocumentReference restaurantDoc = restaurantQuery.docs.first.reference;
      await restaurantDoc.update({'isVip': true});

      // Remove the request from the vipRequests collection
      await FirebaseFirestore.instance
          .collection('vipRequests')
          .doc(email)
          .delete();

      // Add a message to the messages collection
      await FirebaseFirestore.instance.collection('messages').add({
        'emailAdmin': email,
        'message': 'Your Restaurant has become VIP',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Restaurant marked as VIP successfully!'.tr)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating VIP status: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchRestaurantDetails(String email) async {
    try {
      QuerySnapshot restaurantQuery = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('emailAdmin', isEqualTo: email)
          .get();

      if (restaurantQuery.docs.isEmpty) {
        return null;
      }

      return restaurantQuery.docs.first.data() as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          // Navigate to the target page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDeVIPRestaurantsPage(),
            ),
          );
        },
        child: const Icon(Icons.star),
      ),
      backgroundColor: mainColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        centerTitle: true,
        title:  Text('VIP Requests'.tr),
        backgroundColor: mainColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('vipRequests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return  Center(
              child: Text('No VIP requests available.'.tr),
            );
          }

          final vipRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vipRequests.length,
            itemBuilder: (context, index) {
              final request = vipRequests[index];
              final email = request.id; // Email used as the document ID

              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchRestaurantDetails(email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      color: mainColor,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const ListTile(
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return  Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Restaurant details not found'.tr),
                      ),
                    );
                  }

                  final restaurant = snapshot.data!;
                  final name = restaurant['name'] ?? 'Unknown Name';
                  final imageUrl = restaurant['image'] ?? '';
                  final phone = restaurant['phone'] ?? 'Unknown Phone';

                  return Card(
                    color: mainColor2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                                width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.restaurant, size: 50),
                        title: Text(name),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: $phone'),
                            Text('Reason: ${request['reason']}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _makeRestaurantVIP(email),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(accentColor),
                          ),
                          child: Text(
                            'Make VIP'.tr,
                            style: TextStyle(color: mainColor),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
