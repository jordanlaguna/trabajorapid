import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajorapid/components/burbleChat/burble_chat.dart';
import 'package:trabajorapid/services/chat/chat_services.dart';

class ChatHome extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String idS;

  const ChatHome({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.idS,
  }) : super(key: key);

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController messageTextController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isModalShown = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _checkForPendingTrabajos();
  }

  void _markMessagesAsRead() async {
    try {
      List<String> userIds = [_auth.currentUser!.uid, widget.receiverUserID]
        ..sort();
      String chatRoomId = userIds.join('_');
      CollectionReference messagesRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages');
      QuerySnapshot messagesSnapshot =
          await messagesRef.where('read', isEqualTo: false).get();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in messagesSnapshot.docs) {
        if (doc['receiverId'] == _auth.currentUser!.uid) {
          batch.update(messagesRef.doc(doc.id), {'read': true});
        }
      }
      await batch.commit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking messages as read: $e')),
      );
    }
  }

  void _sendMessage() async {
    if (messageTextController.text.isNotEmpty) {
      try {
        await _chatServices.sendMessage(
            widget.receiverUserID, messageTextController.text);
        messageTextController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  Future<void> createOrUpdateTrabajo(
      String estado, String uidReceptor, String idS) async {
    try {
      DocumentReference trabajoRef = FirebaseFirestore.instance
          .collection('trabajos')
          .doc(uidReceptor)
          .collection('salas')
          .doc(idS);

      DocumentSnapshot trabajoDoc = await trabajoRef.get();

      if (!trabajoDoc.exists) {
        await trabajoRef.set({
          'estado': estado,
          'uidReceptor': uidReceptor,
          'uidEmisor': _auth.currentUser!.uid,
          'idEmpleo': idS,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await trabajoRef.update({'estado': estado});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating or updating trabajo: $e')),
      );
    }
  }

  void _solidForm() async {
    if (widget.idS.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Función no permitida')),
      );
      return;
    }
    await createOrUpdateTrabajo('pendiente', widget.receiverUserID, widget.idS);
  }

  void _checkForPendingTrabajos() {
    FirebaseFirestore.instance
        .collection('trabajos')
        .doc(widget.receiverUserID)
        .collection('salas')
        .where('estado', isEqualTo: 'pendiente')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['uidReceptor'] == _auth.currentUser!.uid &&
            doc['uidEmisor'] == widget.receiverUserID) {
          if (!isModalShown) {
            isModalShown = true;
            _showConfirmDialog(context, doc);
          }
        } else if (doc['uidEmisor'] == _auth.currentUser!.uid &&
            doc['uidReceptor'] == widget.receiverUserID) {
          if (!isModalShown) {
            isModalShown = true;
            _showConfirmDialogEmisor(context, doc);
          }
        }
      }
    });
  }

  Future<void> _showConfirmDialogEmisor(
      BuildContext context, DocumentSnapshot doc) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    DocumentSnapshot? servicioDoc = await _fetchServicio(doc['idEmpleo']);

    Navigator.of(context).pop();

    if (servicioDoc == null || !servicioDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron datos del servicio.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var servicioData = servicioDoc.data() as Map<String, dynamic>;
        return AlertDialog(
          title: const Text('Confirmación'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Seguro que quieres aceptar la oferta?'),
              const SizedBox(height: 10),
              Text('ID Empleo: ${doc['idEmpleo']}'),
              Text('Estado: ${doc['estado']}'),
              const SizedBox(height: 10),
              Text('Tipo de Servicio: ${servicioData['tipoServicio']}'),
              Text('Contenido: ${servicioData['contenido']}'),
              Text('Tipo de Oferta: ${servicioData['tipoOferta']}'),
              Text('Título: ${servicioData['titulo']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Atrás'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isModalShown = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmDialog(
      BuildContext context, DocumentSnapshot doc) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    DocumentSnapshot? servicioDoc = await _fetchServicio(doc['idEmpleo']);

    Navigator.of(context).pop();

    if (servicioDoc == null || !servicioDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron datos del servicio.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var servicioData = servicioDoc.data() as Map<String, dynamic>;
        return AlertDialog(
          title: const Text('Confirmación'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Seguro que quieres aceptar la oferta?'),
              const SizedBox(height: 10),
              Text('ID Empleo: ${doc['idEmpleo']}'),
              Text('Estado: ${doc['estado']}'),
              const SizedBox(height: 10),
              Text('Tipo de Servicio: ${servicioData['tipoServicio']}'),
              Text('Contenido: ${servicioData['contenido']}'),
              Text('Tipo de Oferta: ${servicioData['tipoOferta']}'),
              Text('Título: ${servicioData['titulo']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isModalShown = false;
                });
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('trabajos')
                    .doc(widget.receiverUserID)
                    .collection('salas')
                    .doc(doc.id)
                    .update({'estado': 'aceptado'});
                Navigator.of(context).pop();
                setState(() {
                  isModalShown = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<DocumentSnapshot?> _fetchServicio(String idEmpleo) async {
    try {
      DocumentSnapshot servicioDoc = await FirebaseFirestore.instance
          .collection('servicios')
          .doc(idEmpleo)
          .get();
      return servicioDoc;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching servicio: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.receiverUserEmail,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.receiverUserID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? userData =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  if (userData != null && userData.containsKey('isActive')) {
                    bool isActive = userData['isActive'];

                    return Container(
                      width: 16,
                      margin: const EdgeInsets.only(left: 5),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: isActive
                            ? const Color.fromARGB(255, 64, 174, 67)
                            : Colors.red,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
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
        widget.receiverUserID,
        _auth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            height: 50,
            width: 50,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }
        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    bool isMe = (data['senderId'] == _auth.currentUser!.uid);

    IconData iconData = data['read'] ? Icons.done_all : Icons.done;
    Timestamp timestamp = data['timestamp'] as Timestamp;

    DateTime dateTime = timestamp.toDate();
    String hour = '${dateTime.hour}';
    String minute = '${dateTime.minute}'.padLeft(2, '0');

    String formattedTime = '$hour:$minute';

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0, top: 7.0),
          child: Text(
            data['senderName'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 3.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) const Flexible(child: SizedBox()),
            Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                BurbleChat(
                  message: "${data['message']}",
                  isMe: isMe,
                ),
                Padding(
                  padding: isMe
                      ? const EdgeInsets.only(
                          right: 5.0,
                        )
                      : const EdgeInsets.only(
                          left: 16.0,
                        ),
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            if (isMe) const SizedBox(width: 2.0),
            Container(
              margin: const EdgeInsets.only(top: 25.0),
              child: Icon(
                iconData,
                size: 18,
                color: const Color.fromARGB(255, 84, 43, 145),
              ),
            ),
          ],
        ),
      ],
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
            icon: const Icon(Icons.check_box),
            onPressed: _solidForm,
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
