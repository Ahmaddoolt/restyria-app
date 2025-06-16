import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// ignore: unused_import
import 'package:flutter_map/flutter_map.dart'; // Ensure this is used if required
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'dart:io';

import '../../shared/app_colors.dart';
import '../home/home_screen.dart';
import 'select_location.dart';

class CreateRestaurantPage extends StatefulWidget {
  const CreateRestaurantPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateRestaurantPageState createState() => _CreateRestaurantPageState();
}

class _CreateRestaurantPageState extends State<CreateRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _socialMediaController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _phoneNumber = TextEditingController();

  String? _emailAdmin;
  File? _imageFile;
  String? _selectedType;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isDelivery = false;
  String? selectedOption;

  final _firestore = FirebaseFirestore.instance;
  final _imagePicker = ImagePicker();
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    try {
      final email = await _secureStorage.read(key: 'email');
      setState(() {
        _emailAdmin = email ?? 'No email found';
      });
    } catch (e) {
      _showSnackbar('Error fetching admin email: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final storage = FirebaseStorage.instance;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = storage.ref().child('restaurant_images/$fileName');

    try {
      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> _createRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      _showSnackbar('Please select an image for the restaurant.'.tr);
      return;
    }

    if (_selectedLocation == null ||
        _locationNameController.text.trim().isEmpty) {
      _showSnackbar('Please select a location and enter its name.'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final existingRestaurants = await _firestore
          .collection('restaurants')
          .where('emailAdmin', isEqualTo: _emailAdmin)
          .get();

      if (existingRestaurants.docs.isNotEmpty) {
        _showSnackbar('You can only create one restaurant.'.tr);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String imageUrl = await _uploadImage(_imageFile!);

      final restaurantData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
        'locationName': _locationNameController.text.trim(),
        'phone': _phoneNumber.text.trim(),
        'socialMedia': _socialMediaController.text.trim(),
        'type': _selectedType,
        'emailAdmin': _emailAdmin,
        'image': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'isVip': false,
        'isDelivery': _isDelivery,
        "isActive": false,
      };

      final restaurantRef =
          await _firestore.collection('restaurants').add(restaurantData);

      // Schedule subcollection
      final daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      final timeSlots = [
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

      for (var day in daysOfWeek) {
        final scheduleData = {for (var slot in timeSlots) slot: true};
        await restaurantRef.collection('schedule').doc(day).set(scheduleData);
      }

      _showSnackbar('Wait For Admin approval!'.tr);
      _resetForm();
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Generate the default schedule with all time slots set to false
  // Map<String, Map<String, bool>> _getDefaultSchedule() {
  //   final timeSlots = [
  //     '10-11',
  //     '11-12',
  //     '12-13',
  //     '13-14',
  //     '14-15',
  //     '15-16',
  //     '16-17',
  //     '17-18',
  //     '18-19',
  //     '19-20',
  //     '20-21',
  //     '21-22',
  //     '22-23',
  //     '23-24',
  //   ];

  //   final daysOfWeek = [
  //     'Monday',
  //     'Tuesday',
  //     'Wednesday',
  //     'Thursday',
  //     'Friday',
  //     'Saturday',
  //     'Sunday'
  //   ];

  //   Map<String, Map<String, bool>> schedule = {};

  //   for (var day in daysOfWeek) {
  //     schedule[day] = {};
  //     for (var slot in timeSlots) {
  //       schedule[day]![slot] = true; // Default to "Booked" (false)
  //     }
  //   }

  //   return schedule;
  // }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _socialMediaController.clear();
    _locationNameController.clear();
    _phoneNumber.clear();
    setState(() {
      _imageFile = null;
      _selectedType = null;
      _selectedLocation = null;
    });
  }

  Future<void> _selectLocation() async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationPage(
          initialLocation: _selectedLocation,
        ),
      ),
    );
    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: accentColor),
          filled: true,
          fillColor: mainColor2,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: mainColor,
        title: Text('Create Restaurant'.tr),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: mainColor,
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : const Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton(
                        backgroundColor: accentColor,
                        onPressed: _pickImage,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Restaurant Name'.tr,
                          icon: Icons.restaurant,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a name'.tr : null,
                        ),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description'.tr,
                          icon: Icons.description,
                          maxLines: 3,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter a description'.tr
                              : null,
                        ),
                        _buildTextField(
                          controller: _locationNameController,
                          label: 'Location Name'.tr,
                          icon: Icons.location_on,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter the location name'.tr
                              : null,
                        ),
                        _buildTextField(
                          controller: _phoneNumber,
                          label: 'Phone'.tr,
                          icon: Icons.phone,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter Phone Number'.tr
                              : null,
                        ),
                        _buildTextField(
                          controller: _socialMediaController,
                          label: 'Social Media Link (Optional)'.tr,
                          icon: Icons.link,
                          validator: (value) => null, // Optional field
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          dropdownColor: mainColor,
                          value: _selectedType,
                          onChanged: (value) => setState(() {
                            _selectedType = value!;
                          }),
                          items: [
                            'Fast Food',
                            'Fine Dining',
                            'Cafe',
                            'Casual Dining',
                            'Buffet',
                            'Bistro',
                            'Pizzeria',
                            'Food Truck',
                            'Sushi Bar',
                            'Vegan/Vegetarian',
                            'Ethnic Cuisine',
                            'Wine Bar',
                            'Sports Bar',
                            'Family Style',
                            'Pop-Up Restaurant',
                          ]
                              .map((type) => DropdownMenuItem(
                                    value:
                                        type, // Keep English value for saving
                                    child:
                                        Text(type.tr), // Show translated value
                                  ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Restaurant Type'.tr,
                            prefixIcon:
                                Icon(Icons.restaurant_menu, color: accentColor),
                            filled: true,
                            fillColor: mainColor2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) =>
                              value == null ? 'Please select a type'.tr : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedOption,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.bike_scooter, color: accentColor),
                            labelText: "Is there delivery?".tr,
                            border: const OutlineInputBorder(),
                          ),
                          items: ["Yes", "No"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            selectedOption = newValue;
                            if (newValue == "Yes") {
                              setState(() {
                                _isDelivery = true;
                              });
                            } else {
                              setState(() {
                                _isDelivery = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                          ),
                          child: Text(
                            _selectedLocation == null
                                ? 'Select Location on Map'.tr
                                : 'Change Location'.tr,
                            style: TextStyle(color: mainColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedLocation != null)
                          const Text(
                            'Location selected)',
                            style: TextStyle(color: Colors.green),
                          )
                        else
                          const Text(
                            'No location selected yet.',
                            style: TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          Center(
                            child: CircularProgressIndicator(
                              color: accentColor,
                            ),
                          ),
                        if (_isLoading == false)
                          ElevatedButton(
                            onPressed: _createRestaurant,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                            ),
                            child: Text(
                              'Create Restaurant'.tr,
                              style: TextStyle(
                                  color: mainColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
