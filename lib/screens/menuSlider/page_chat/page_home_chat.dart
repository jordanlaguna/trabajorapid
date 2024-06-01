import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trabajorapid/screens/menuSlider/page_chat/page_chat.dart';
import 'dart:async';

class PageChat extends StatefulWidget {
  const PageChat({Key? key}) : super(key: key);

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String searchQuery = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoDeleteOldMessages();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // start the once a day timer to delete old messages
  void _startAutoDeleteOldMessages() {
    _timer = Timer.periodic(const Duration(days: 1), (timer) {
      _deleteOldMessages();
    });
  }

  // delete messages older than 8 days
  Future<void> _deleteOldMessages() async {
    var chatRooms =
        await FirebaseFirestore.instance.collection('chatRooms').get();
    for (var chatRoom in chatRooms.docs) {
      var messagesRef = chatRoom.reference.collection('messages');
      var messagesSnapshot = await messagesRef.get();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var messageDoc in messagesSnapshot.docs) {
        if (_isMessageOlderThanEightDays(messageDoc['timestamp'])) {
          batch.delete(messageDoc.reference);
        }
      }
      await batch.commit();
    }
  }

  // check if a message is older than 8 days and to delete it
  bool _isMessageOlderThanEightDays(Timestamp timestamp) {
    var now = DateTime.now();
    var messageDate = timestamp.toDate();
    var difference = now.difference(messageDate);
    return difference.inDays >= 8;
  }

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

        String currentUserID = _auth.currentUser!.uid;

        final filteredDocs = snapshot.data!.docs.where((doc) {
          return (doc['name'] as String)
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) &&
              doc['uid'] != currentUserID;
        }).toList();

        return ListView(
          children: filteredDocs.map(
            (doc) {
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
                      onPressed: (context) async {
                        bool confirmed = await _showConfirmationDialog(context);
                        if (confirmed) {
                          await _deleteMessages(chatRoomID, doc['name']);
                        }
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
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.hasError) {
                      return const Text('Error');
                    }
                    if (messageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text('Loading..');
                    }

                    String lastMessageTime = '';
                    if (messageSnapshot.hasData &&
                        messageSnapshot.data!.docs.isNotEmpty) {
                      var lastMessage = messageSnapshot.data!.docs.first;
                      lastMessageTime =
                          formatTimestamp(lastMessage['timestamp']);
                    }

                    int unreadMessageCount = messageSnapshot.data!.docs
                        .where((msg) =>
                            msg['senderId'] != currentUserID && !msg['read'])
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
                                        snapshot.data != null &&
                                        snapshot.data!.isNotEmpty) {
                                      return GestureDetector(
                                        onTap: () {
                                          _showImageDialog(
                                              context, snapshot.data!);
                                        },
                                        child: Hero(
                                          tag: doc['uid'],
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(
                                              snapshot.data!,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return GestureDetector(
                                        onTap: () {
                                          _showDefaultIconDialog(context);
                                        },
                                        child: Hero(
                                          tag: doc['uid'],
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.blue[50],
                                            child: const Icon(
                                              Icons.account_circle,
                                              size: 50,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
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
                                      Text(
                                        lastMessageTime,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
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

  Future<void> _showImageDialog(BuildContext context, String imageUrl) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Hero(
              tag: imageUrl,
              child: Image.network(imageUrl),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDefaultIconDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Hero(
              tag: 'defaultIcon',
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.blue[50],
                child: const Icon(
                  Icons.account_circle,
                  size: 200,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // get the photo of a user from the database
  Future<String?> getUserPhotoColletion(String userID) async {
    if (userID.isEmpty) {
      return null;
    }

    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      final DocumentSnapshot document = await users.doc(userID).get();

      if (document.exists) {
        Map<String, dynamic>? userData =
            document.data() as Map<String, dynamic>?;

        if (userData != null &&
            userData['photoURL'] != null &&
            userData['photoURL'].isNotEmpty) {
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

  // format the timestamp of a message
  String formatTimestamp(Timestamp timestamp) {
    initializeDateFormatting('es_ES', null);
    var now = DateTime.now();
    var messageDate = timestamp.toDate();
    var difference = now.difference(messageDate);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(messageDate);
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return capitalize(DateFormat('EEEE', 'es_ES').format(messageDate));
    } else {
      return DateFormat('dd/MM/yyyy', 'es_ES').format(messageDate);
    }
  }

  // capitalize the first letter of a string
  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  // modal of confirmation to delete a chat
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Confirmar eliminación',
              style: TextStyle(
                fontFamily: 'Monserrat',
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            content: const Text(
              '¿Estás seguro de que deseas eliminar esta conversación?',
              style: TextStyle(
                  fontFamily: 'Monserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontFamily: 'Monserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(
                    fontFamily: 'Monserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // delete messages and show a snackbar
  Future<void> _deleteMessages(String chatRoomID, String userName) async {
    var messagesRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .collection('messages');

    var messagesSnapshot = await messagesRef.get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var messageDoc in messagesSnapshot.docs) {
      batch.delete(messageDoc.reference);
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Eliminando la conversación de $userName'),
      ),
    );
  }
}
