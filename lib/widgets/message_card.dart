import 'dart:developer';

import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../helper/date_time_format_util.dart';
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
    return APIS.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
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
            padding: EdgeInsets.all(mq.width * 0.04),
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
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black),
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
            padding: EdgeInsets.all(mq.width * 0.04),
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
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
