import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:gustoro/screens/home/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import '../screens/admin/admin_active_resturants.dart';
import '../screens/admin/admin_approve_vip.dart';
import '../screens/create_rest/create_rest.dart';
import '../screens/messages_screen.dart';
import '../screens/own_resturant.dart';
import '../screens/vip_request.dart';
import 'app_colors.dart';

class CustomDrawerAdmin extends StatefulWidget {
  const CustomDrawerAdmin({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomDrawerAdmin> createState() => _CustomDrawerAdminState();
}

class _CustomDrawerAdminState extends State<CustomDrawerAdmin> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> signOut(BuildContext context) async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');

    // await _auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: mainColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    color: accentColor,
                    size: 125,
                  ),

                  // child: Image.asset(
                  //   'assets/1024.png',
                  //   width: 150,
                  //   height: 180,
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.home,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  'Home'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontSize: 18),
                ),
                onTap: () {
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const Login(),
                  //     ));
                },
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.restaurant,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  'Create Restaurant'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontSize: 18),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateRestaurantPage()));
                },
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.storefront,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  'My Restaurant'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontSize: 18),
                ),
                onTap: () async {
                  final email = await _storage.read(key: 'email');
                  // print(email);
                  if (email != null) {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantByEmailPage(emailAdmin: email),
                      ),
                    );
                  } else {
                    // Handle the case where email is null (e.g., show an error or log a message)
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Unable to retrieve email. Please try again.'.tr),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.star,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  'Vip Restaurant'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontSize: 18),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestVIPPage()));
                },
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.message,
                    color: accentColor,
                  ),
                ),
                title: Row(children: [
                  Text(
                    'Messages'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        fontSize: 18),
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                ]),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MessagesPage()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 0, left: 15, top: 0, right: 15),
                    child: Icon(
                      Icons.language,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Language'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  PopupMenuButton<String>(
                    color: mainColor2,
                    icon: Padding(
                      padding: const EdgeInsets.only(
                          top: 0, left: 0, right: 0, bottom: 0),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: accentColor,
                      ),
                    ),
                    onSelected: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      if (value == 'English') {
                        Get.updateLocale(const Locale('en', ''));
                        await prefs.setString('language', 'en');
                      } else if (value == 'Arabic') {
                        Get.updateLocale(const Locale('ar', ''));
                        await prefs.setString('language', 'ar');
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'English',
                          child: Text(
                            'English',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Arabic',
                          child: Text(
                            'Arabic',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.request_page,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  'Vip Requests'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontSize: 18),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminVIPRequestsPage()));
                },
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.local_activity_rounded,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  'Resturants Active'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontSize: 18),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdmmiActiveResturant()));
                },
              ),
              ListTile(
                leading: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                ),
                title: Text(
                  'Logout'.tr,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 18),
                ),
                onTap: () {
                  signOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
