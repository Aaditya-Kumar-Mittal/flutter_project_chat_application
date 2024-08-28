import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

//global object for media query and size handling of the device screen size
late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //Settings for opening the app in full-screen mode and in portrait orientation
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    //Code for Flutter Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 84, 83, 83),
          elevation: 1,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.normal, color: Colors.white, fontSize: 22),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      home: const SplashScreen(),
    );
  }
}
