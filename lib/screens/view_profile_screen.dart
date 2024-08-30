import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helper/date_time_format_util.dart';
import '../main.dart';
import '../models/chat_user.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(

          //sets the background color of the view_profile_screen
          backgroundColor: const Color.fromRGBO(167, 233, 255, 1.0),
          //app bar

          //display the name of the user in the view profile screen appbar
          appBar: AppBar(title: Text(widget.user.name)),

          //user about
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              Text(
                  DateTimeFormatUtil.getLastMessageTime(
                      context: context,
                      time: widget.user.createdAt,
                      showYear: true),
                  style: const TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),

          //body
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  // //user profile picture
                  // ProfileImage(
                  //   size: mq.height * .2,
                  //   url: widget.user.image,
                  // ),

                  //image from the server
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),

                  // for adding some space
                  SizedBox(height: mq.height * .03),

                  // user email label
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 25)),

                  // for adding some space
                  SizedBox(height: mq.height * .02),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Text(widget.user.about,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
