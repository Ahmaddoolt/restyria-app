import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gustoro/screens/splash.dart';
import 'package:gustoro/shared/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('language');

  Locale locale;
  if (languageCode == 'ar') {
    locale = const Locale('ar', '');
  } else {
    locale = const Locale('en', '');
  }

  runApp(
    GetMaterialApp(
      translations: Lang(),
      debugShowCheckedModeBanner: false,
      locale: locale, // Set the loaded locale here
      home: const Splash(),
      title: 'GustroGuide',
      theme: ThemeData.dark(), // Set the app theme here if needed
    ),
  );
}
