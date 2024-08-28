import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 84, 83, 83),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
      ),
      body: Column(
        children: [
          _chatInput(),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Container(
      margin: EdgeInsets.only(top: mq.height * 0.05),
      child: InkWell(
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                //back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                //user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .3),
                  child: CachedNetworkImage(
                    width: mq.height * 0.055,
                    height: mq.height * 0.055,
                    imageUrl: widget.user.image,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(
                  width: mq.width * 0.03,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      "Last seen not available",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Color.fromRGBO(53, 223, 4, 1.0),
                      size: 26,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          hintText: "Type something...",
                          hintStyle:
                              TextStyle(color: Colors.blue, fontSize: 17),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          //show message button
          MaterialButton(
            shape: CircleBorder(),
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            onPressed: () {},
            color: Colors.white,
            child: Icon(
              Icons.send,
              color: Colors.blue,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
