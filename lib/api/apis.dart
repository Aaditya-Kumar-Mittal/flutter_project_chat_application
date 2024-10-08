import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

//Class for CRUD APIS
class APIS {
  //global object for storing self information
  static late ChatUser self;

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for accessing Firebase Push Notifications
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission();

    await firebaseMessaging.getToken().then((token) {
      if (token != null) {
        self.pushToken = token;
        log('Push Token: $token');
      } else {
        log('Push Token not working!');
      }
    });
  }

  //Getter and Read Function (R -> Read)
  //to return current user
  static User get user => auth.currentUser!;

  //Checker Function
  //for checking if the user exists or not?
  //If the user exists, we don't the data to be overridden
  //returns true or false
  static Future<bool> userExists() async {
    //it is assumed that the user has already been created and signed in
    //await -> wait for while it fetches the info
    //firestore.collection("users") -> lookup in the collection users of the database
    //doc(auth.currentUser!.uid) -> Checks a specific document
    //! -> that it cannot be null
    //get() -> To access that document and exists checks its existing
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //Getter and Read Function (R -> Read) and Create Function (C -> Create)
  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      //Checks if the user exists
      if (user.exists) {
        self = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIS.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //Create Function (C -> Create)
  //for creating a new User
  //called when the user is not accessible
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      image: user.photoURL.toString(),
      isOnline: false,
      about: "Hey, I'm using Chat App",
      lastActive: time,
      createdAt: time,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //Getter and Read Function (R -> Read) and Delete Function (D -> Delete)
  //for getting all users from the firestore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    //this is for since when we log in, we don't want our chat to be displayed
    //the code will display all other connected users except our self profile
    //get users whose id is not equal to the uid of the logged in user
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //Update Function (U -> Update)
  static Future<void> updateUserInfo() async {
    //Updates data on the document. Data will be merged with any existing document data.
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': self.name, 'about': self.about});
  }

  //Update Function (U -> Update)
  static Future<void> updateProfilePicture(File file) async {
    //Extract the extension of the file by split the last string after last .
    final fileExtension = file.path.split('.').last;

    log('Image Extension : $fileExtension');

    //Create a reference to the file and store in profile_pictures folder to avoid duplication
    final ref =
        storage.ref().child('profile_pictures/${user.uid}.$fileExtension');

    //put the file in the reference
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$fileExtension"))
        .then((p0) {
      log("Data Transferred: ${p0.bytesTransferred / 1000} kB");
    });

    //Updating our image in firestore database
    self.image = await ref.getDownloadURL();
    //Try to fetch the download url of the file and update the user information
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': self.image});

    log('Profile picture updated successfully');
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id',
            isEqualTo:
                chatUser.id) //If the chatUser.id is equal to the users id
        .snapshots();
  }

  // update online or last active status of user --> tells if the user is online or not
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': self.pushToken,
    });
  }

  ///*************Chat Screen Related APIS *******************

  //chats(collection) --> conversation_id (doc) --> messages(collection) -->message(doc)

  //for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from the firebase Reading Operation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending messages
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //Message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    //Preparing a doc id
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');

    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    final docRef = firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef
          .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
    } else {
      log('Message document not found: ${message.sent}');
    }

    /*firestore.collection('chats/${getConversationID(message.fromId)}/messages/').doc(message.sent).update({'read': DateTime.now().millisecondsSinceEpoch.toString()});*/
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  //future void -> takes time to execute and returns nothing
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //Extract the extension of the file by split the last string after last .
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path and unique since stored with time name of time in milliseconds
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
