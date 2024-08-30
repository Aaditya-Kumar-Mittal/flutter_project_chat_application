import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_chat_application/widgets/profile_dialog.dart';

import '../api/apis.dart';
import '../helper/date_time_format_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message if (null --> no message)
  Message? _message;

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
        child: StreamBuilder(
          stream: APIS.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            if (list.isNotEmpty) {
              _message = list[0];
            }
            return ListTile(
              //user profile picture
              leading: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user));
                },
                child: ClipRRect(
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
              ),

              //user name
              title: Text(
                widget.user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              //user about or last message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'Image'
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
              ),

              //chat message time
              trailing: _message == null
                  ? Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ) //show nothing when message is sent
                  : _message!.read.isEmpty && _message!.fromId != APIS.user.uid
                      ? //for unread message
                      Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        )
                      : //for message sent time
                      Text(
                          DateTimeFormatUtil.getLastMessageTime(
                              context: context, time: _message!.sent),
                          style: const TextStyle(
                              color: Colors.black26, fontSize: 15),
                        ),
            );
          },
        ),
      ),
    );
  }
}
