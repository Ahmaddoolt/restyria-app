import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../shared/app_colors.dart';
import '../../signup/signup_screen.dart';
import '../home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _transform;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool isLoading = false;
  bool _isPasswordVisible = false; // Track password visibility

  @override
  void initState() {
    super.initState();
    _checkStoredCredentials();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    )..addListener(() {
        setState(() {});
      });

    _transform = Tween<double>(begin: 2, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkStoredCredentials() async {
    setState(() => isLoading = true);
    try {
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');

      if (email == null || password == null) {
        // print("No stored credentials found.");
        setState(() => isLoading = false);
        return;
      }

      // print("Stored Email: $email, Password: $password");

      final querySnapshot = await _firestore
          .collection('uzer') // Ensure correct collection name
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid stored credentials.')),
        );
      }
    } catch (e) {
      // print("Error reading credentials: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loginUser() async {
    setState(() => isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      // print("Checking Firestore for: $email, $password");

      final querySnapshot = await _firestore
          .collection('uzer') // Ensure correct collection name
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // print("User found!");

        await _secureStorage.write(key: 'email', value: email);
        await _secureStorage.write(key: 'password', value: password);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // print("No user found.");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      // print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                child: Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _transform.value,
                    child: Container(
                      width: size.width * .9,
                      height: size.width * 1.1,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15, left: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  color: accentColor,
                                  size: 40,
                                ),
                                Image.asset(
                                  'assets/resto.png',
                                  // height: size.height * 0.1,
                                  width: 75,
                                  // fit: BoxFit.contain,
                                ),
                                Icon(
                                  Icons.dinner_dining,
                                  color: accentColor,
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Sign In'.tr,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(.7),
                            ),
                          ),
                          const SizedBox(),
                          buildTextField(
                            controller: emailController,
                            icon: Icons.email_outlined,
                            hintText: 'Email...'.tr,
                            isPassword: false,
                          ),
                          buildTextField(
                            controller: passwordController,
                            icon: Icons.lock_outline,
                            hintText: 'Password...'.tr,
                            isPassword: true,
                          ),
                          component2('LOGIN'.tr, 2.6, loginUser),
                          const SizedBox(),
                          RichText(
                            text: TextSpan(
                              text: 'Create a new Account'.tr,
                              style: TextStyle(
                                color: accentColor.withOpacity(0.5),
                                fontSize: 15,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage()),
                                  );
                                },
                            ),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            ),
        ],
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
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white.withOpacity(.8)),
        obscureText: isPassword ? !_isPasswordVisible : false,
        keyboardType:
            isPassword ? TextInputType.text : TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(.7),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white.withOpacity(.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText.tr,
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
          string.tr,
          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
