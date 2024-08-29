import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_chat_application/api/apis.dart';
import '../main.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      //Helps to set the mode back to exit from full screen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      //Sets the color of the status bar on top depending on the screen UI
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white));

      //Checks if the user is already logged in, moves directly to HomePage()
      if (APIS.auth.currentUser != null) {
        log("\nCurrent User: ${APIS.auth.currentUser}");
        //Navigate to Home Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        //Navigate to Login Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Initializing media query for getting the screen size
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(167, 233, 255, 1.0),
      body: Stack(
        children: [
          /*----------------------------------------------*/
          Positioned(
            top: mq.height * .25,
            width: mq.width * .6,
            right: mq.width * .2,
            child: Image.asset("images/icon.png"),
          ),
          /*----------------------------------------------*/
          Positioned(
            bottom: mq.height * .25,
            width: mq.width * 0.8,
            left: mq.width * .1,
            child: const Center(
              child: Text(
                "A CHAT APPLICATION",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          /*----------------------------------------------*/
          Positioned(
            bottom: mq.height * .10,
            width: mq.width * 0.8,
            left: mq.width * .1,
            child: const Center(
              child: Text(
                "Flutter Training Project",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          /*----------------------------------------------*/
          Positioned(
            bottom: mq.height * .06,
            width: mq.width * 1,
            child: const Center(
              child: Text(
                "❤️ Made by Aaditya Kumar 📲",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          /*----------------------------------------------*/
        ],
      ),
    );
  }
}
