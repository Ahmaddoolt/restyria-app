import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';

import 'home/home_screen.dart';

class RequestVIPPage extends StatefulWidget {
  const RequestVIPPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RequestVIPPageState createState() => _RequestVIPPageState();
}

class _RequestVIPPageState extends State<RequestVIPPage> {
  final TextEditingController _reasonController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _submitRequest() async {
    try {
      final String? email = await _secureStorage.read(key: 'email');
      if (email == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email not found. Please log in again.')),
        );
        return;
      }

      // Step 1: Check if the user has a restaurant
      QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('emailAdmin', isEqualTo: email)
          .get();

      if (restaurantSnapshot.docs.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'You must have a restaurant before submitting a VIP request.')),
        );
        return;
      }

      // Step 2: Check if VIP request already exists
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('vipRequests').doc(email);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You have already submitted a VIP request.'.tr)),
        );
        return;
      }

      // Step 3: Submit the VIP request
      await docRef.set({
        'email': email,
        'reason': _reasonController.text,
        'status': 'Pending',
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('VIP request submitted successfully!'.tr)),
      );

      _reasonController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    }
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
        centerTitle: true,
        title: Text('Request VIP Restaurant'.tr),
        backgroundColor: mainColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 500,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/vip.png',
                      height: isSmallScreen ? 200 : 300,
                      width: isSmallScreen ? 200 : 300,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Request to make your restaurant VIP'.tr,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3, // Allows multi-line input
                      decoration: InputDecoration(
                        labelText:
                            'Enter your offer to apply for this request with an effective means of contact'
                                .tr,
                        alignLabelWithHint:
                            true, // Aligns the label for multi-line TextField
                        border: const OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        fontSize: 14, // Adjust font size for better readability
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(accentColor),
                        ),
                        child: Text(
                          'Submit VIP Request'.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: mainColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
