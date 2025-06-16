import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../shared/app_colors.dart';
import '../make_revestion.dart';
import '../own_resturant.dart';
import 'menu_table.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final String? id;
  const RestaurantDetailPage(
      {Key? key, required this.restaurant, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final latitude = restaurant['latitude'];
    final longitude = restaurant['longitude'];
    // final aa = restaurant['name'];
    // print(id);
    // print(aa);
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          restaurant['name'] ?? 'Restaurant Details',
          style: TextStyle(
              color: accentColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              if (restaurant['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    restaurant['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child:
                      Icon(Icons.image, color: Colors.grey.shade700, size: 50),
                ),
              const SizedBox(height: 16),

              // Details Section
              _buildDetailsCard(
                context,
                children: [
                  _buildInfoRow(
                    context: context, // Pass the context here

                    icon: Icons.restaurant,
                    text: restaurant['name'] ?? 'No Name Available'.tr,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      context: context, // Pass the context here

                      icon: Icons.location_on,
                      text: (restaurant['locationName'] ?? 'Unknown Location')
                          .toString()
                          .tr),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      context: context, // Pass the context here

                      icon: Icons.fastfood,
                      text:
                          (restaurant['type'] ?? 'Unknown Type').toString().tr),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context: context, // Pass the context here

                    icon: Icons.phone,
                    text:
                        (restaurant['phone'] ?? 'Unknown phone').toString().tr,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context: context, // Pass the context here
                    icon: Icons.bike_scooter,
                    text:
                        '${'Delivery?'.tr} : ${restaurant['isDelivery'] == true ? 'Yes'.tr : 'No'.tr}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context: context, // Pass the context here
                    icon: Icons.link,
                    text:
                        '${restaurant['socialMedia'] == "" ? "None" : restaurant['socialMedia'] ?? 'Unknown Type'.tr}',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description Section
              Text(
                'Description:'.tr,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor),
              ),
              const SizedBox(height: 8),
              Text(
                (restaurant['description'] ?? 'No description provided')
                    .toString()
                    .tr,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
              ),

              const SizedBox(height: 20),

              // Map Button
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (latitude != null && longitude != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantMapPage(
                                latitude: latitude, longitude: longitude),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.map),
                    label: Text(
                      'View on Map'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            // Force the type to match List<Map<String, dynamic>>
                            return MenuTablePage(
                              menuItems: (restaurant['menu'] as List)
                                  .map(
                                      (item) => Map<String, dynamic>.from(item))
                                  .toList(),
                            );
                          },
                        ),
                      );
                    },
                    label: Text(
                      'View Menu'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationRequestPage(
                            restaurantId: id,
                            restaurantName: restaurant['name'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.book_online),
                    label: Text(
                      'Reservation'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context,
      {required List<Widget> children}) {
    return Card(
      elevation: 4,
      color: mainColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }
  //  required BuildContext context,

  Widget _buildInfoRow({
    required BuildContext context, // Add context parameter here
    required IconData icon,
    required String text,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Row(
      children: [
        Icon(icon, color: accentColor),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              // Check if the icon is for a link and if the URL is valid
              if (icon == Icons.link && text.isNotEmpty && text != "None".tr) {
                // Ensure the URL starts with a valid protocol (http:// or https://)
                final url = text.startsWith('http') ? text : 'https://$text';

                final uri = Uri.tryParse(url);
                // print("Trying to launch URL: $url");

                if (uri != null) {
                  // Check if the URL can be launched
                  bool canLaunch = await canLaunchUrl(uri);
                  // print("Can launch URL: $canLaunch");

                  if (canLaunch) {
                    // Launch the URL in the in-app web view
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    // Show a Snackbar if the URL cannot be launched
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open the link: $url')),
                    );
                  }
                } else {
                  // Handle invalid URL format
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid URL format')),
                  );
                }
              }
            },
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: primaryTextColor,
                fontWeight: fontWeight,
                decoration: icon == Icons.link
                    ? TextDecoration.underline
                    : null, // Underline only if it's a link
              ),
              maxLines: 2, // Limits to 2 lines
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
