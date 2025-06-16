import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:gustoro/screens/home/home_screen.dart';

import '../../shared/app_colors.dart';
import '../home/login/login_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  Future<void> signUpUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();
    final String phone = phoneController.text.trim();

    // Validate fields
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please fill in all fields'.tr)),
      );
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Passwords do not match'.tr)),
      );
      return;
    }

    try {
      // Check if the email already exists
      final querySnapshot = await _firestore
          .collection('uzer')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Email is already registered'.tr)),
        );
        return;
      }

      // Add the user to Firestore
      await _firestore.collection('uzer').add({
        'email': email,
        'password': password, // Not recommended for production
        'phone': phone,
      });

      // Store email and password securely
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Signup successful!'.tr)),
      );

      // Navigate to login screen
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mainColor,
                  mainColor2,
                  mainColor,
                  mainColor2,
                ],
              ),
            ),
            child: Container(
              width: size.width * .9,
              height: size.height * .7,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 33, 33, 36),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 90,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt,
                    color: accentColor,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign Up'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    controller: emailController,
                    icon: Icons.email_outlined,
                    hintText: 'Email...'.tr,
                    isPassword: false,
                  ),
                  buildTextField(
                    controller: phoneController,
                    icon: Icons.phone_outlined,
                    hintText: 'Phone Number...'.tr,
                    isPassword: false,
                  ),
                  buildPasswordField(
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    hintText: 'Password...'.tr,
                    isPasswordVisible: isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  buildPasswordField(
                    controller: confirmPasswordController,
                    icon: Icons.lock_outline,
                    hintText: 'Confirm Password...'.tr,
                    isPasswordVisible: isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  component2('SIGN UP'.tr, 2.6, signUpUser),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: "Already have an account? ".tr,
                      style: TextStyle(color: accentColor.withOpacity(0.7)),
                      children: [
                        TextSpan(
                          text: "Sign In".tr,
                          style: TextStyle(
                            color: accentColor.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required bool isPassword,
  }) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width / 8,
      width: size.width / 1.22,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: size.width / 30),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white.withOpacity(.8)),
        obscureText: isPassword,
        keyboardType:
            isPassword ? TextInputType.text : TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(.7),
          ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle:
              TextStyle(fontSize: 14, color: Colors.white.withOpacity(.5)),
        ),
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width / 8,
      width: size.width / 1.22,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: size.width / 30),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: TextStyle(color: Colors.white.withOpacity(.8)),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(.7),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: onVisibilityToggle,
          ),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle:
              TextStyle(fontSize: 14, color: Colors.white.withOpacity(.5)),
        ),
      ),
    );
  }

  Widget component2(String string, double width, VoidCallback voidCallback) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: voidCallback,
      child: Container(
        height: size.width / 8,
        width: size.width / width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          string,
          style: TextStyle(color: mainColor, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
