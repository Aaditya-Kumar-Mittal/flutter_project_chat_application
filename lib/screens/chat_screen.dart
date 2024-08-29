import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_chat_application/widgets/message_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //lost for storing all messages
  List<Message> _list = [];

  //text controller for handling text messages
  final _textController = TextEditingController();

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
      backgroundColor: const Color.fromRGBO(167, 233, 255, 1.0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: APIS.getAllMessages(widget.user),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const SizedBox();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    // log('Data in Messages: ${jsonEncode(data![0].data())}');
                    _list =
                        data?.map((e) => Message.fromJson(e.data())).toList() ??
                            [];

                    /*
                    //for test clear the list for the first time
                    list.clear();
                    //Dummy data for messages
                    list.add(Message(
                        toId: 'xyz',
                        msg: "Hello",
                        read: '',
                        type: Type.text,
                        fromId: APIS.user.uid,
                        sent: '12:00 AM'));
                    list.add(Message(
                        toId: APIS.user.uid,
                        msg: "Hi",
                        read: '',
                        type: Type.text,
                        fromId: 'xyz',
                        sent: '12:05 AM'));
                    */

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemCount: _list.length,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(top: mq.height * 0.003),
                        itemBuilder: (context, index) {
                          return MessageCard(message: _list[index]);
                          // return Text('Message : ${list[index]}');
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "Say Hi! 👋👋",
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }
                }
              },
            ),
          ),
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
                      style: const TextStyle(
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
          vertical: mq.height * 0.04, horizontal: mq.width * 0.03),
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
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
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
            shape: const CircleBorder(),
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIS.sendMessage(widget.user, _textController.text);
                _textController.text = '';
              }
            },
            color: Colors.white,
            child: const Icon(
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
