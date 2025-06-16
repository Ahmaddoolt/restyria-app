import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import 'detail_resturant.dart';
import 'package:get/get.dart';

class VipRestaurantsList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VipRestaurantsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "VIP Restaurants".tr,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(width: 5),
              Icon(Icons.star, color: accentColor),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('restaurants')
                .where('isVip', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No VIP Restaurants Yet".tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              final vipRestaurants = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vipRestaurants.length,
                itemBuilder: (context, index) {
                  final docData = vipRestaurants[index].data() as Map<String, dynamic>;
                  final restaurantId = vipRestaurants[index].id;

                  // Extract latitude and longitude from GeoPoint
                  final GeoPoint? location = docData['location'];
                  final restaurant = {
                    ...docData,
                    'latitude': location?.latitude,
                    'longitude': location?.longitude,
                    'id': restaurantId, // Include the ID in the map
                  };

                  final imageUrl = restaurant['image'] ?? '';
                  final phoneNumber =
                      restaurant['locationName'] ?? 'Unknown Number';
                  final restaurantName = restaurant['name'] ?? 'Unknown Name';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 100, maxWidth: 200),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailPage(
                                restaurant: restaurant,
                                id: restaurantId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: mainColor2.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: 185,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    restaurantName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Text(
                                    phoneNumber,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          secondaryTextColor.withOpacity(0.85),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}