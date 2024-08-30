// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_chat_application/screens/profile_screen.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Global declaration of the list variable so that it is accessible across the whole class
  List<ChatUser> list = [];

  //Implementation of Read Operation on database
  //For reading the database and storing searched items  in searchList variable
  final List<ChatUser> _searchList = [];
  //var for storing search status
  bool _isSearching = false;

  //First Method which is called when screen is loaded
  @override
  void initState() {
    super.initState();
    APIS.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIS.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIS.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIS.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //WillPopScope is only applicable to Scaffold and when it called on the current screen
        //if search is on and back is pressed then close search
        //or else simple close current screen on back button click
        /*
        * PopScope(
        * canPop: !_isSearching,
        * onPopInvoked: (didPop) { if (_isSearching) {
        *   setState(() { _isSearching = !_isSearching; });
        *   log('if:$_isSearching');
        * } else {
        * //Our normal will pop scope code
        * }
        * */
        onWillPop: () {
          if (_isSearching) {
            //if search is on and back is pressed then close search and move to home screen
            setState(() {
              _isSearching = !_isSearching;
            });
            //false means do nothing and just stay on home screen
            return Future.value(false);
          } else {
            //or else simple close current screen on back button click
            //returning true means perform the normal back functionality
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: _isSearching
                ? Center(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter name, email ...",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      autofocus: true,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, letterSpacing: 1),
                      onChanged: (val) {
                        //Logic for search operation

                        //Clear the previous search List
                        _searchList.clear();

                        for (var i in list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                            setState(() {
                              _searchList;
                            });
                          }
                        }
                      },
                    ),
                  )
                : const Text("Chat Application"),
            leading: const Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              //more options user button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: APIS.self)),
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: FutureBuilder(
            future: APIS.getSelfInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("An error occurred!"));
              } else {
                return StreamBuilder(
                  stream: APIS.getAllUsers(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        list = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (list.isNotEmpty) {
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : list[index]);
                            },
                            itemCount:
                                _isSearching ? _searchList.length : list.length,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(top: mq.height * 0.003),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "No connections found!",
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
