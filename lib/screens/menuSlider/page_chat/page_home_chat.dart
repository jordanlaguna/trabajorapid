import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trabajorapid/screens/menuSlider/page_chat/page_chat.dart';

class PageChat extends StatefulWidget {
  const PageChat({Key? key}) : super(key: key);

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mensajes',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 45,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar',
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide: BorderSide(
                      color: Colors.blue.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide: BorderSide(
                      color: Colors.blue.shade600,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildUserList()),
        ],
      ),
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

        final filteredDocs = snapshot.data!.docs.where((doc) {
          return (doc['name'] as String)
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
        }).toList();

        return ListView(
          children: filteredDocs.map(
            (doc) {
              String currentUserID = _auth.currentUser!.uid;
              List<String> chatRoomParticipants =
                  [currentUserID, doc['uid']].cast<String>().toList();
              chatRoomParticipants.sort();
              String chatRoomID = chatRoomParticipants.join('_');
              return Slidable(
                key: Key(doc['uid']),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        FirebaseFirestore.instance
                            .collection('chatRooms')
                            .doc(chatRoomID)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${doc['name']} eliminado')),
                        );
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Eliminar',
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
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
                          margin: const EdgeInsets.symmetric(vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            title: Row(
                              children: [
                                FutureBuilder<String?>(
                                  future: getUserPhotoColletion(doc['uid']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.grey.shade200,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.blue[50],
                                        child: const Icon(Icons.error),
                                      );
                                    } else if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                          snapshot.data!,
                                        ),
                                      );
                                    } else {
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.blue[50],
                                        child: const Icon(
                                          Icons.account_circle,
                                          size: 50,
                                          color: Colors.blue,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        doc['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      if (doc.data() is Map &&
                                          (doc.data() as Map)
                                              .containsKey('isActive'))
                                        CircleAvatar(
                                          backgroundColor:
                                              doc['isActive'] == true
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
                                    idS: '',
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
                ),
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
