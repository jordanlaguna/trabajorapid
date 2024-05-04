// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajorapid/screens/menuSlider/page_chat/page_chat.dart';

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
      body: _buildUserList(),
      backgroundColor: Colors.blue[50],
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
          children: snapshot.data!.docs.map(
            (doc) {
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
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          title: Row(
                            children: [
                              CircleAvatar(
                                child: ClipOval(
                                  child: FutureBuilder<String?>(
                                    future: getUserPhotoColletion(doc['uid']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else {
                                        if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        } else {
                                          if (snapshot.data != null) {
                                            return Image.network(
                                              snapshot.data!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            );
                                          } else {
                                            return const Icon(
                                                Icons.account_circle,
                                                size: 25);
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(doc['name']),
                                    const SizedBox(width: 5),
                                    if (doc.data() is Map &&
                                        (doc.data() as Map)
                                            .containsKey('isActive'))
                                      CircleAvatar(
                                        backgroundColor: doc['isActive'] == true
                                            ? Colors.green
                                            : Colors.red,
                                        radius: 6,
                                      ),
                                  ],
                                ),
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
                      ),
                      const Divider(
                        color: Colors.white,
                        height: 0.0,
                        thickness: 2.0,
                      ),
                    ],
                  );
                },
              );
            },
          ).toList(),
        );
      },
    );
  }
}

Future<String?> getUserPhotoColletion(String userID) async {
  if (userID.isEmpty) {
    return null;
  }

  try {
    // Si no es un inicio de sesión de Google o Facebook, obtenemos la foto de Firestore
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final DocumentSnapshot document = await users.doc(userID).get();

    if (document.exists) {
      Map<String, dynamic>? userData = document.data() as Map<String, dynamic>?;

      if (userData != null && userData['photoURL'] != null) {
        return userData['photoURL'];
      } else {
        return null;
      }
    } else {
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}
