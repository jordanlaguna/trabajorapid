import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/model/message/message.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    String senderName = '';

    // verify if the user is signed in with Google
    if (_auth.currentUser!.providerData
        .any((info) => info.providerId == 'google.com')) {
      senderName = _auth.currentUser!.displayName ?? '';
    } else {
      senderName = await _getUserName();
    }

    Message newMessage = Message(
      senderId: currentUserId,
      senderName: senderName,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firebaseFirestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

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

  // method to get the name of the user from the Firestore database
  Future<String> _getUserName() async {
    String userName = '';

    try {
      User? user = _auth.currentUser;

      // if the user is not null, get the user document from the Firestore database
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firebaseFirestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          // get the name from the user document and store it in the userName variable
          userName = (userDoc.data() as Map<String, dynamic>?)?['name'] ?? '';
        }
      }
    } catch (error) {
      print('Error al obtener el nombre del usuario: $error');
    }

    return userName;
  }
}
