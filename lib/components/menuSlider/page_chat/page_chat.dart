import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/components/burbleChat/burble_chat.dart';
import 'package:trabajorapid/services/chat/chat_services.dart';

class ChatHome extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatHome({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController messageTextController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (messageTextController.text.isNotEmpty) {
      await _chatServices.sedMessage(
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
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffB81736),
                Color(0xff281537),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          //message
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildMessageInput(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  //build message list
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

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //alignment of the message item
    var alignment = (data['senderId'] == _auth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: (data['senderId'] == _auth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderId'] == _auth.currentUser!.uid
            ? MainAxisAlignment.end
            : MainAxisAlignment.start),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 7.0),
            child: Text(
              data['senderEmail'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 7.0),
          BurbleChat(message: data['message'])
        ],
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageTextController,
              decoration: const InputDecoration(
                hintText: 'Escribir mensaje...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
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
