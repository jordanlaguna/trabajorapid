// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajorapid/model/message/message.dart';

class ChatServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    String senderName = await _getSenderName();

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

  Future<String> _getSenderName() async {
    String senderName = '';

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firebaseFirestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          senderName = (userDoc.data() as Map<String, dynamic>?)?['name'] ?? '';
        }
      }
    } catch (error) {
      print('Error obtaining user name: $error');
    }

    return senderName;
  }
}
