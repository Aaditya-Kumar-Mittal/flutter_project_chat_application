import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_chat_application/screens/view_profile_screen.dart';
import 'package:flutter_project_chat_application/widgets/message_card.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/date_time_format_util.dart';
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

  //var for check on show images button
  bool _showEmoji = false;

  //var for upload status of images
  bool _isUploading = false;

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
    return GestureDetector(
      //hides the keyboard on tapping anywhere on the screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        //if emojis are shown & back button is pressed then hide emojis
        //or else simple close current screen on back button click
        canPop: false,
        onPopInvoked: (_) {
          if (_showEmoji) {
            setState(() => _showEmoji = !_showEmoji);
            return;
          }

          // some delay before pop
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              if (Navigator.canPop(context)) Navigator.pop(context);
            } catch (e) {
              log('ErrorPop: $e');
            }
          });
        },
        child: Scaffold(
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
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
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
              if (_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _chatInput(),
              if (_showEmoji)
                SafeArea(
                  child: SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController:
                          _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        height: 500,
                        emojiViewConfig: EmojiViewConfig(
                          columns: 9,
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                          backgroundColor:
                              const Color.fromRGBO(167, 233, 255, 1.0),
                        ),
                        swapCategoryAndBottomBar: false,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      margin: EdgeInsets.only(top: mq.height * 0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIS.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
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
                        fit: BoxFit.fill,
                        imageUrl: (list.isNotEmpty)
                            ? list[0].image
                            : widget.user.image,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
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
                          (list.isNotEmpty) ? list[0].name : widget.user.name,
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : DateTimeFormatUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : DateTimeFormatUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white54,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.035, horizontal: mq.width * 0.03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
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
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      maxLines: null,
                      decoration: const InputDecoration(
                          hintText: "Type something...",
                          hintStyle:
                              TextStyle(color: Colors.blue, fontSize: 17),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Picking multiple images
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);

                      // uploading & sending image one by one
                      for (var i in images) {
                        log('Image Path: ${i.path}');
                        setState(() => _isUploading = true);
                        await APIS.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),

                  //take image from camera button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() => _isUploading = true);
                        await APIS.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
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
                APIS.sendMessage(widget.user, _textController.text, Type.text);
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
