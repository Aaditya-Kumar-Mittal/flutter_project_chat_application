// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Private Variables

  bool _isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Time Scheduler code for Login Page Animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    //Since the following function is a Future function, we will use .then() method to direct our program flow
    //Future function is used in chain with the then method which is called after the work is done by the preceding function.

    //Showing the progress bar
    Dialogs.showProgressIndicator(context);

    _signInWithGoogle().then((user) async {
      //Hide the progress bar
      Navigator.pop(context);
      if (user != null) {
        //Once verified that user is not null...

        //Check if the user exists or not
        if (await APIS.userExists()) {
          log("User : ${user.user}");
          log("Additional User Info : ${user.additionalUserInfo}");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          //Create the new User
          //This code creates a new user
          APIS.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      //Checks whether user is connected with the internet or not...
      await InternetAddress.lookup('google.com');

      // Trigger the authentication flow...
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request...
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential...
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential...
      return await APIS.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(
          context, "Something went wrong (Check the internet, please!)");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /*----------------------------------------------*/
      //App Bar for Home Page
      appBar: AppBar(
        //Removal of any leading icons
        automaticallyImplyLeading: false,
        title: const Text(
          "Welcome to Chat App",
        ),
      ),
      /*----------------------------------------------*/
      body: Stack(
        children: [
          /*----------------------------------------------*/
          AnimatedPositioned(
            top: mq.height * .15,
            width: mq.width * .6,
            right: _isAnimate ? mq.width * .20 : -mq.width * .6,
            duration: const Duration(milliseconds: 900),
            child: Image.asset('images/icon.png'),
          ),
          /*----------------------------------------------*/
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            height: mq.height * 0.07,
            width: mq.width * .9,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset('images/google.png', height: mq.height * 0.05),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 19),
                  children: [
                    TextSpan(text: "Log In with "),
                    TextSpan(
                        text: "Google",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 84, 83, 83),
                  shape: const StadiumBorder(),
                  elevation: 1),
            ),
          ),
          /*----------------------------------------------*/
        ],
      ),
      /*----------------------------------------------*/
    );
  }
}
