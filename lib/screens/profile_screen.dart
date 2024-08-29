// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  //Variable for getting the user details
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //For hiding the keyboard on double taping anywhere on the screen
      onDoubleTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        /*----------------------------------------------*/
        backgroundColor: Colors.white,
        /*----------------------------------------------*/
        //App Bar for Home Page
        appBar: AppBar(
          title: const Text(
            "Profile Screen",
          ),
        ),
        /*----------------------------------------------*/
        //floating button to add new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              //for showing progress dialog
              Dialogs.showProgressIndicator(context);

              //log out from the application
              await APIS.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding the progress dialog
                  Navigator.pop(context);

                  //for moving to home screen
                  Navigator.pop(context);

                  //Removes home screen from back stack and never moves back to home screen, stay on login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              "Logout",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        /*----------------------------------------------*/
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //sized box for spacing
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  //User Profile Picture
                  Stack(
                    children: [
                      _image != null
                          ?
                          //local image
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * 0.2,
                                height: mq.height * 0.2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :
                          //image from the server
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * 0.2,
                                height: mq.height * 0.2,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.image,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: -5,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          color: Colors.blue,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  //sized box for spacing
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  //User Email Info
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  //sized box for spacing
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  //User Name Field
                  TextFormField(
                    initialValue: widget.user.name,
                    //If given a value store it in the name variable else if null store a null string
                    onSaved: (value) => APIS.self.name = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "This is a required field",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 2, color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      hintText: "Enter your name",
                      label: const Text("User Name"),
                    ),
                  ),
                  //sized box for spacing
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  //User About Info
                  TextFormField(
                    initialValue: widget.user.about,
                    //If given a value store it in the about variable else if null store a null string
                    onSaved: (value) => APIS.self.about = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "This is a required field",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      hintText: "e.g. Feeling Happy",
                      label: const Text("About"),
                    ),
                  ),
                  //sized box for spacing
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  //Info Update Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .4, mq.height * 0.06),
                    ),
                    onPressed: () {
                      //the validations are correct
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIS.updateUserInfo().then((value) {
                          log('Inside the validator. User Info Updated!');
                          Dialogs.showSnackbar(
                              context, 'Profile Updated Successfully!');
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontSize: 18),
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

  //bottom sheet modal for picking and image for the user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap:
                true, //Show the modal according to the size of the content
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              const Center(
                child: Text(
                  "Pick Profile Picture!",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                height: mq.height * .02,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        //Printing the picked image
                        log("Image Path : ${image.path} -- MimeType: ${image.mimeType}");

                        setState(() {
                          _image = image.path;
                        });

                        //Updating the image in firebase storage
                        APIS.updateProfilePicture(File(_image!));
                        //When the image has been picked, hide the dialog box.
                        Navigator.pop(context);
                      }
                    },
                    child: Center(child: Image.asset('images/addImage.png')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        //Printing the picked image
                        log("Image Path : ${image.path} -- MimeType: ${image.mimeType}");

                        setState(() {
                          _image = image.path;
                        });
                        //Updating the image in firebase storage
                        APIS.updateProfilePicture(File(_image!));
                        //When the image has been picked, hide the dialog box.
                        Navigator.pop(context);
                      }
                    },
                    child: Center(child: Image.asset('images/camera.png')),
                  ),
                ],
              )
            ],
          );
        });
  }
}
