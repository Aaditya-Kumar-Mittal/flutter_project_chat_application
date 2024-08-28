import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: mq.width * 0.01),
      color: const Color.fromRGBO(143, 222, 255, 1.0),
      child: InkWell(
        onTap: () {
          //For navigation to chat screen of the connected user
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: ListTile(
            //user profile picture
            leading: ClipRRect(
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

            //user name
            title: Text(
              widget.user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            //user about
            subtitle: Text(
              widget.user.about,
              maxLines: 1,
            ),
            trailing: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
            )),
      ),
    );
  }
}
