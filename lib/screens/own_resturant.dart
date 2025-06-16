import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:gustoro/screens/add_menu.dart';
import 'package:gustoro/screens/create_rest/select_location.dart';
import 'package:gustoro/screens/restaurant_schedule.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

import '../../shared/app_colors.dart';
import 'create_rest/create_rest.dart';
import 'home/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class RestaurantByEmailPage extends StatefulWidget {
  final String emailAdmin;

  const RestaurantByEmailPage({Key? key, required this.emailAdmin})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantByEmailPageState createState() => _RestaurantByEmailPageState();
}

class _RestaurantByEmailPageState extends State<RestaurantByEmailPage> {
  Map<String, dynamic>? restaurantData;
  String? restaurantId;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }

  Future<void> _editDescription(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: restaurantData!['description'] ?? '',
    );

    final updatedDescription = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          title: Text(
            'Edit Description'.tr,
            style: TextStyle(color: accentColor),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Restaurant Description'.tr,
              hintText: 'Enter the new description'.tr,
            ),
            maxLines:
                4, // You can adjust the number of lines for the description.
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(
                'Save'.tr,
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (updatedDescription != null && updatedDescription.isNotEmpty) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('emailAdmin', isEqualTo: widget.emailAdmin)
            .get()
            .then((snapshot) => snapshot.docs.first.reference);

        await docRef.update({'description': updatedDescription});

        setState(() {
          restaurantData!['description'] = updatedDescription;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Description updated successfully'.tr)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update description: $e')),
        );
      }
    }
  }

  Future<void> _editFoodType(BuildContext context) async {
    final List<String> foodTypes = {
      'Fast Food',
      'Fine Dining',
      'Cafe',
      'Casual Dining',
      'Buffet',
      'Food Truck',
      'Bistro',
      'Takeout',
      'Vegetarian',
      'Vegan',
      'Pizzeria',
      'Steakhouse',
      'Barbecue',
      'Sushi',
      'Bakery',
    }.toList(); // Remove duplicates

    String selectedFoodType = foodTypes.contains(restaurantData!['type'])
        ? restaurantData!['type']
        : foodTypes[0];

    final updatedFoodType = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          title: Text(
            'Edit Restaurant Type'.tr,
            style: TextStyle(color: accentColor),
          ),
          content: DropdownButton<String>(
            dropdownColor: mainColor,
            value: selectedFoodType,
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                selectedFoodType = newValue!;
              });
            },
            items: foodTypes.map((foodType) {
              return DropdownMenuItem<String>(
                value: foodType,
                child: Text(foodType),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel'.tr,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedFoodType);
              },
              child: Text(
                'Save'.tr,
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (updatedFoodType != null && updatedFoodType.isNotEmpty) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('emailAdmin', isEqualTo: widget.emailAdmin)
            .get()
            .then((snapshot) => snapshot.docs.first.reference);

        await docRef.update({'type': updatedFoodType});

        setState(() {
          restaurantData!['type'] = updatedFoodType;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant type updated successfully'.tr)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update food type: $e')),
        );
      }
    }
  }

  Future<void> _editSocialMedia(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: restaurantData!['socialMedia'] ??
          '', // Use the existing social media link
    );

    final updatedSocialMedia = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          title: Text(
            'Edit Social Media Link'.tr,
            style: TextStyle(color: accentColor),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Social Media Link'.tr,
              hintText: 'Enter the new social media link'.tr,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(
                'Save'.tr,
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (updatedSocialMedia != null && updatedSocialMedia.isNotEmpty) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('emailAdmin', isEqualTo: widget.emailAdmin)
            .get()
            .then((snapshot) => snapshot.docs.first.reference);

        await docRef.update({
          'socialMedia': updatedSocialMedia
        }); // Update the social media field

        setState(() {
          restaurantData!['socialMedia'] =
              updatedSocialMedia; // Update local data
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Social Media link updated successfully'.tr)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update social media link: $e')),
        );
      }
    }
  }

  Future<void> _editName(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: restaurantData!['name'] ?? '',
    );

    final updatedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          title: Text(
            'Edit Name'.tr,
            style: TextStyle(color: accentColor),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Restaurant Name'.tr,
              hintText: 'Enter the new name'.tr,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(
                'Save'.tr,
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (updatedName != null && updatedName.isNotEmpty) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('emailAdmin', isEqualTo: widget.emailAdmin)
            .get()
            .then((snapshot) => snapshot.docs.first.reference);

        await docRef.update({'name': updatedName});

        setState(() {
          restaurantData!['name'] = updatedName;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name updated successfully'.tr)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $e')),
        );
      }
    }
  }

  Future<void> _editphone(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: restaurantData!['phone'] ?? '',
    );

    final updatedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          title: Text('Edit phone number'.tr),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Phone Number'.tr,
              hintText: 'Enter the new number'.tr,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(
                'Save',
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (updatedName != null && updatedName.isNotEmpty) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('emailAdmin', isEqualTo: widget.emailAdmin)
            .get()
            .then((snapshot) => snapshot.docs.first.reference);

        await docRef.update({'phone': updatedName});

        setState(() {
          restaurantData!['phone'] = updatedName;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('phone number updated successfully'.tr)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $e')),
        );
      }
    }
  }

  Future<void> _editLocation(BuildContext context) async {
    // Current location to be shown on map (if any)
    LatLng? initialLocation;
    if (restaurantData!['location'] != null) {
      initialLocation = LatLng(
        restaurantData!['location'].latitude,
        restaurantData!['location'].longitude,
      );
    }

    final LatLng? newLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        return SelectLocationPage(initialLocation: initialLocation);
      },
    );

    if (newLocation != null) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('emailAdmin', isEqualTo: widget.emailAdmin)
            .get()
            .then((snapshot) => snapshot.docs.first.reference);

        // Create a GeoPoint with the selected location
        final newGeoPoint =
            GeoPoint(newLocation.latitude, newLocation.longitude);

        await docRef.update({'location': newGeoPoint});

        setState(() {
          restaurantData!['location'] = newGeoPoint;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location updated successfully'.tr)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update location: $e')),
        );
      }
    }
  }

  Future<void> _editLocationName(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: restaurantData!['locationName'] ?? '',
    );

    final updatedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          title: Text('Edit Location Name'.tr),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Location Name'.tr,
              hintText: 'Enter the new name'.tr,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(
                'Save'.tr,
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (updatedName != null && updatedName.isNotEmpty) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('emailAdmin', isEqualTo: widget.emailAdmin)
            .get()
            .then((snapshot) => snapshot.docs.first.reference);

        await docRef.update({'locationName': updatedName});

        setState(() {
          restaurantData!['locationName'] = updatedName;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name updated successfully'.tr)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $e')),
        );
      }
    }
  }

  Future<void> _fetchRestaurantData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('emailAdmin', isEqualTo: widget.emailAdmin)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          restaurantData = querySnapshot.docs.first.data();
          restaurantId = querySnapshot.docs.first.id;
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No restaurant found for the given email'.tr)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch restaurant: $e')),
      );
    }
  }

  Future<void> _editImage(BuildContext context) async {
    // ignore: no_leading_underscores_for_local_identifiers
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected'.tr)),
      );
      return;
    }

    // Show loading while uploading
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading image...'.tr)),
    );

    try {
      // Upload the image to Firebase Storage
      final file = File(image.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('restaurant_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Update the image URL in the Firestore database
      final docRef = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('emailAdmin', isEqualTo: widget.emailAdmin)
          .get()
          .then((snapshot) => snapshot.docs.first.reference);

      await docRef.update({'image': imageUrl});

      setState(() {
        restaurantData!['image'] =
            imageUrl; // Assuming `restaurantData` stores the image URL
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image updated successfully'.tr)),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (restaurantData == null) {
      return Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          centerTitle: true,
          title: Text(
            'Restaurant Details'.tr,
            style: TextStyle(
                color: accentColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: mainColor,
          iconTheme: IconThemeData(color: accentColor),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_outlined,
                  size: 80, color: Colors.grey.shade600),
              const SizedBox(height: 16),
              Text(
                'No restaurant found for this email.'.tr,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateRestaurantPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(
                  'Create Restaurant'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: accentColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final GeoPoint? geoPoint = restaurantData!['location'] as GeoPoint?;
    final latitude = geoPoint?.latitude;
    final longitude = geoPoint?.longitude;

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          restaurantData!['name'] ?? 'Restaurant Details',
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
              Stack(
                children: [
                  if (restaurantData!['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        restaurantData!['image'],
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
                      child: Icon(Icons.image,
                          color: Colors.grey.shade700, size: 50),
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                        icon: Icon(Icons.edit, color: accentColor),
                        onPressed: () => _editImage(context)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailsCard(
                context,
                children: [
                  _buildInfoRow(
                    icon: Icons.restaurant,
                    text: restaurantData!['name'] ?? 'No Name Available',
                    fontWeight: FontWeight.bold,
                    edit: () => _editName(context),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      icon: Icons.location_on,
                      text:
                          restaurantData!['locationName'] ?? 'Unknown Location',
                      edit: () => _editLocationName(context)),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      icon: Icons.fastfood,
                      text:
                          'Type: ${restaurantData!['type'] ?? 'Unknown Type'}',
                      edit: () => _editFoodType(context)),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      icon: Icons.phone,
                      text:
                          'Phone: ${restaurantData!['phone'] ?? 'Unknown phone'}',
                      edit: () => _editphone(context)),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      icon: Icons.link,
                      text:
                          'Link: ${restaurantData!['socialMedia'] == "" ? "None" : restaurantData!['socialMedia'] ?? 'None Link'}',
                      edit: () => _editSocialMedia(context)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Description:'.tr,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor),
                  ),
                  const Expanded(
                      child: SizedBox(
                    height: 0,
                  )),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editDescription(context),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                restaurantData!['description'] ?? 'No description provided',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (latitude != null && longitude != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantMapPage(
                                  latitude: latitude,
                                  longitude: longitude,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Location data is unavailable'),
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
                      IconButton(
                          onPressed: () => _editLocation(context),
                          icon: const Icon(Icons.edit))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMenuPage(emailAdmin: widget.emailAdmin),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: Text(
                    'Add Menu'.tr,
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantSchedulePage(
                          restaurantId: restaurantId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book_online),
                  label: Text(
                    'Reservations'.tr,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required VoidCallback edit,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Row(
      children: [
        Icon(icon, color: accentColor),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Text(
            text,
            style: TextStyle(
                fontSize: 16, color: primaryTextColor, fontWeight: fontWeight),
            maxLines: 2, // Limits to 2 lines
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 1,
          child: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: edit,
          ),
        )
      ],
    );
  }
}

class RestaurantMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const RestaurantMapPage(
      {Key? key, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Restaurant Location',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(latitude, longitude),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(latitude, longitude),
                builder: (ctx) =>
                    Icon(Icons.location_pin, size: 40, color: accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
