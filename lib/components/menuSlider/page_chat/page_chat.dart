// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajorapid/components/burbleChat/burble_chat.dart';
import 'package:trabajorapid/services/chat/chat_services.dart';

class ChatHome extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatHome({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  }) : super(key: key);

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController messageTextController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    try {
      // Obtener los IDs de usuario ordenados alfabéticamente
      List<String> userIds = [_auth.currentUser!.uid, widget.receiverUserID]
        ..sort();

      String chatRoomId = userIds.join('_');

      CollectionReference messagesRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages');

      QuerySnapshot messagesSnapshot =
          await messagesRef.where('read', isEqualTo: false).get();

      for (var doc in messagesSnapshot.docs) {
        messagesRef.doc(doc.id).update({'read': true});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _sendMessage() async {
    if (messageTextController.text.isNotEmpty) {
      await _chatServices.sendMessage(
          widget.receiverUserID, messageTextController.text);
      messageTextController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 65, 111, 223),
                Color.fromARGB(255, 110, 174, 231),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          const SizedBox(height: 10),
        ],
      ),
      backgroundColor: Colors.blue[50],
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatServices.getMessages(
            widget.receiverUserID, _auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    bool isMe = (data['senderId'] == _auth.currentUser!.uid);

    IconData iconData = data['read'] ? Icons.done_all : Icons.done;

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 7.0),
            child: Text(
              data['senderName'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 3.0),
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (!isMe) const Flexible(child: SizedBox()),
            BurbleChat(
              message: data['message'],
              isMe: isMe,
            ),
            if (isMe) const SizedBox(width: 2.0),
            Container(
              margin: const EdgeInsets.only(top: 33.0),
              child: Icon(
                iconData,
                size: 18,
                color: const Color.fromARGB(255, 84, 43, 145),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final windowSize = MediaQuery.of(context).size;
    return Container(
      width: windowSize.width * 0.99,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageTextController,
              decoration: const InputDecoration(
                hintText: 'Escribir mensaje...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
