import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';


class AdminDeVIPRestaurantsPage extends StatefulWidget {
  const AdminDeVIPRestaurantsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDeVIPRestaurantsPageState createState() =>
      _AdminDeVIPRestaurantsPageState();
}

class _AdminDeVIPRestaurantsPageState extends State<AdminDeVIPRestaurantsPage> {
  Future<void> _removeVIPStatus(String restaurantId) async {
    try {
      // Update the isVip field to false for the restaurant document
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .update({'isVip': false});

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
            content: Text('Restaurant VIP status removed successfully!'.tr)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating VIP status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(builder: (context) => const HomeScreen()),
        //     );
        //   },
        // ),
        // centerTitle: true,
        title:  Text('VIP Restaurants'.tr),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .where('isVip', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return  Center(
              child: Text('No VIP restaurants available.'.tr),
            );
          }

          final vipRestaurants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vipRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = vipRestaurants[index];
              final restaurantId = restaurant.id;
              final name = restaurant['name'] ?? 'Unknown Name';
              final imageUrl = restaurant['image'] ?? '';
              final phone = restaurant['phone'] ?? 'Unknown Phone';

              return Card(
                color: mainColor2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.restaurant, size: 50),
                  title: Text(name),
                  subtitle: Text('Phone: $phone'),
                  trailing: ElevatedButton(
                    onPressed: () => _removeVIPStatus(restaurantId),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(accentColor),
                    ),
                    child: Text(
                      'Remove VIP'.tr,
                      style: TextStyle(color: mainColor),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
