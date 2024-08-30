import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import '../api/apis.dart';
import '../helper/date_time_format_util.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/message.dart';

//for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool mySelf = APIS.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () => _showBottomSheet(mySelf),
      child: mySelf ? _greenMessage() : _blueMessage(),
    );
  }

  //sender or another user message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIS.updateMessageReadStatus(widget.message);
      log('Message Read Status Updated!');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(192, 184, 218, 255),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(21.0),
                  topRight: Radius.circular(21.0),
                  bottomRight: Radius.circular(21.0)),
              border: Border.all(width: 2, color: Colors.blue),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            DateTimeFormatUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  //self user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_sharp,
                color: Colors.blue,
                size: 25,
              ),
            //for adding some space
            SizedBox(
              width: mq.width * .01,
            ),
            //for displaying time
            Text(
              DateTimeFormatUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(192, 197, 255, 176),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(21.0),
                  topRight: Radius.circular(21.0),
                  bottomLeft: Radius.circular(21.0)),
              border: Border.all(width: 2, color: Colors.green),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return SingleChildScrollView(
            child: ListView(
              shrinkWrap: true,
              children: [
                //black divider
                Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(
                      vertical: mq.height * .015, horizontal: mq.width * .4),
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                ),

                //If a text message ---> Copy It
                widget.message.type == Type.text
                    ?
                    //copy option
                    _OptionItem(
                        icon: const Icon(Icons.copy_all_rounded,
                            color: Colors.blue, size: 28),
                        name: 'Copy Text',
                        onTap: () async {
                          await Clipboard.setData(
                                  ClipboardData(text: widget.message.msg))
                              .then((value) {
                            //for hiding bottom sheet
                            Navigator.of(context).pop(mounted);
                            Dialogs.showSnackbar(context, 'Text Copied!');
                          });
                        })
                    :
                    //If a image message --> save or download it.
                    //save option
                    _OptionItem(
                        icon: const Icon(Icons.download_rounded,
                            color: Colors.blue, size: 26),
                        name: 'Save Image',
                        onTap: () async {
                          try {
                            //Print the image url
                            log('Image Url: ${widget.message.msg}');

                            //Store the bytes of the image in a variable
                            final bytes =
                                (await get(Uri.parse(widget.message.msg)))
                                    .bodyBytes;

                            //Get the path of a directory
                            final directory = await getTemporaryDirectory();
                            final file =
                                await File('${directory.path}/we_chat.png')
                                    .writeAsBytes(bytes);
                            log('File Path: ${file.path}');
                            await GallerySaver.saveImage(file.path,
                                    albumName: 'We Chat')
                                .then((success) {
                              //for hiding bottom sheet
                              Navigator.of(context).pop(mounted);
                              if (success != null && success) {
                                Dialogs.showSnackbar(
                                    context, 'Image Successfully Saved!');
                              }
                            });
                          } catch (e) {
                            log('ErrorWhileSavingImg: $e');
                          }
                        }),

                //separator or divider
                if (isMe)
                  Divider(
                    color: Colors.black54,
                    endIndent: mq.width * .04,
                    indent: mq.width * .04,
                  ),

                //edit option
                if (widget.message.type == Type.text && isMe)
                  _OptionItem(
                      icon:
                          const Icon(Icons.edit, color: Colors.blue, size: 26),
                      name: 'Edit Message',
                      onTap: () {
                        Navigator.of(context).pop(mounted);

                        _showMessageUpdateDialog();
                      }),

                //delete option
                if (isMe)
                  _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIS.deleteMessage(widget.message).then((value) {
                        //for hiding bottom sheet
                        Navigator.of(context).pop(mounted);
                      });
                    },
                  ),

                //separator or divider
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

                _OptionItem(
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.blue,
                    ),
                    name:
                        'Sent At: ${DateTimeFormatUtil.getMessageTime(context: context, time: widget.message.sent)}',
                    onTap: () {}),

                _OptionItem(
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.green,
                    ),
                    name: widget.message.read.isEmpty
                        ? 'Read At: Not seen yet'
                        : 'Read At: ${DateTimeFormatUtil.getMessageTime(context: context, time: widget.message.read)}',
                    onTap: () {}),
              ],
            ),
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.of(context).pop(mounted);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      // Check if the widget is still mounted before popping the dialog
                      if (mounted) {
                        // Hide alert dialog
                        Navigator.pop(context);

                        // Now, check again before updating the message
                        if (mounted) {
                          APIS.updateMessage(widget.message, updatedMsg);
                        }
                      }
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(
            children: [
              icon,
              Flexible(
                  child: Text('    $name',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          letterSpacing: 0.5)))
            ],
          ),
        ));
  }
}
