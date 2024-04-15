// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajorapid/components/menuSlider/page_chat/page_chat.dart';

class PageChat extends StatefulWidget {
  const PageChat({Key? key}) : super(key: key);

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: _buildUserList(),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            String currentUserID = _auth.currentUser!.uid;
            List<String> chatRoomParticipants =
                [currentUserID, doc['uid']].cast<String>().toList();
            chatRoomParticipants.sort();
            String chatRoomID = chatRoomParticipants.join('_');
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(chatRoomID)
                  .collection('messages')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading..');
                }
                int unreadMessageCount = snapshot.data!.docs
                    .where((doc) =>
                        doc['senderId'] != currentUserID && !doc['read'])
                    .length;
                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.person_outline_rounded),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(doc['name']),
                          ),
                          if (unreadMessageCount > 0)
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 10,
                              child: Text(
                                unreadMessageCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatHome(
                              receiverUserEmail: doc['name'],
                              receiverUserID: doc['uid'],
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      color: Color.fromARGB(180, 239, 239, 239),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
