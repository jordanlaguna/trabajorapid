import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/model/message/message.dart';

class ChatServices extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //send message
  Future<void> sendMessage(String receiverId, String message) async {
    //get current user
    final String currentUserId = _auth.currentUser!.uid;
    final String currentEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    //construct chat room id using the user id and the receiver id (sorted to ensure uniques)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    //add the message to database
    await _firebaseFirestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get messages from a chat room
  Stream<QuerySnapshot> getMessages(String userId, String otherId) {
    List<String> ids = [userId, otherId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firebaseFirestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
