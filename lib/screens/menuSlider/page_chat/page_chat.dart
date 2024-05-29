import 'dart:async';

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
  final TextEditingController messageTextController = TextEditingController();
  final TextEditingController oferta = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  bool isModalShown = false;
  Timer? _typingTimer;
  final StreamController<bool> _isTypingController =
      StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _checkForPendingTrabajos();

    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });

    if (widget.idS.isNotEmpty) {
      _solidForm();
    }

    messageTextController.addListener(_handleTyping);
  }

  @override
  void dispose() {
    messageTextController.removeListener(_handleTyping);
    messageTextController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _isTypingController.close();
    super.dispose();
  }

  void _handleTyping() {
    if (_typingTimer?.isActive ?? false) _typingTimer?.cancel();
    _isTypingController.add(true);
    _setTypingState(true);

    _typingTimer = Timer(const Duration(seconds: 1), () {
      _isTypingController.add(false);
      _setTypingState(false);
    });
  }

  Future<void> _setTypingState(bool isTyping) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'isTyping': isTyping});
  }

  Future<void> _markMessagesAsRead() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking messages as read: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (messageTextController.text.isNotEmpty) {
      try {
        await _chatServices.sendMessage(
            widget.receiverUserID, messageTextController.text);
        messageTextController.clear();
        _scrollToBottom();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending message: $e')),
          );
        }
      }
    }
  }

  Future<void> createOrUpdateTrabajo(
      String estado, String uidReceptor, String idS) async {
    try {
      QuerySnapshot existingTrabajos = await FirebaseFirestore.instance
          .collection('trabajos')
          .where('uidReceptor', isEqualTo: uidReceptor)
          .where('uidEmisor', isEqualTo: _auth.currentUser!.uid)
          .where('idEmpleo', isEqualTo: idS)
          .get();

      if (existingTrabajos.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('trabajos').add({
          'estado': estado,
          'uidReceptor': uidReceptor,
          'uidEmisor': _auth.currentUser!.uid,
          'idEmpleo': idS,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        String trabajoId = existingTrabajos.docs.first.id;
        await FirebaseFirestore.instance
            .collection('trabajos')
            .doc(trabajoId)
            .update({'estado': estado});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating or updating trabajo: $e')),
        );
      }
    }
  }

  Future<void> _solidForm() async {
    if (widget.idS.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Función no permitida')),
        );
      }
      return;
    }

    await _chatServices.sendMessage(
        widget.receiverUserID, oferta.text = '¡Oferta aceptada!');
    oferta.clear();
    await createOrUpdateTrabajo('Pendiente', widget.receiverUserID, widget.idS);
  }

  void _checkForPendingTrabajos() {
    FirebaseFirestore.instance
        .collection('trabajos')
        .where('estado', isEqualTo: 'Pendiente')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['uidReceptor'] == _auth.currentUser!.uid &&
            doc['uidEmisor'] == widget.receiverUserID) {
          if (!isModalShown) {
            isModalShown = true;
            if (mounted) {
              _showConfirmDialog(context, doc);
            }
          }
        } else if (doc['uidEmisor'] == _auth.currentUser!.uid &&
            doc['uidReceptor'] == widget.receiverUserID) {
          if (!isModalShown) {
            isModalShown = true;
            if (mounted) {
              _showConfirmDialogEmisor(context, doc);
            }
          }
        }
      }
    });
  }

  Future<void> _showConfirmDialogEmisor(
      BuildContext context, DocumentSnapshot doc) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    DocumentSnapshot? servicioDoc = await _fetchServicio(doc['idEmpleo']);

    Navigator.of(context).pop();

    if (servicioDoc == null || !servicioDoc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se encontraron datos del servicio.')),
        );
      }
      return;
    }

    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          var servicioData = servicioDoc.data() as Map<String, dynamic>;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Confirmación',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text(
                    'Solicitó la oferta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tipo de Servicio: ${servicioData['tipoServicio']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Contenido: ${servicioData['contenido']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tipo de Oferta: ${servicioData['tipoOferta']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ofrecido por: ${servicioData['titulo']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Estado: ${doc['estado']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(color: Colors.white),
                ),
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
  }

  Future<void> _showConfirmDialog(
      BuildContext context, DocumentSnapshot doc) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    DocumentSnapshot? servicioDoc = await _fetchServicio(doc['idEmpleo']);

    Navigator.of(context).pop();

    if (servicioDoc == null || !servicioDoc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se encontraron datos del servicio.')),
        );
      }
      return;
    }

    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          var servicioData = servicioDoc.data() as Map<String, dynamic>;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                Text(
                  'Confirmación',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text(
                    '¿Seguro que quieres aceptar la oferta?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Estado: ${doc['estado']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tipo de Servicio: ${servicioData['tipoServicio']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Descripción: ${servicioData['contenido']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tipo de Oferta: ${servicioData['tipoOferta']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ofrecido por: ${servicioData['titulo']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('trabajos')
                      .doc(doc.id)
                      .update({'estado': 'Rechazado'});

                  Navigator.of(context).pop();
                  setState(() {
                    isModalShown = false;
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Sí',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('trabajos')
                      .doc(doc.id)
                      .update({'estado': 'En proceso'});

                  String message = 'Estado: En proceso\n'
                      'Tipo de Servicio: ${servicioData['tipoServicio']}\n'
                      'Descripción: ${servicioData['contenido']}\n'
                      'Tipo de Oferta: ${servicioData['tipoOferta']}\n'
                      'Ofrecido por: ${servicioData['titulo']}';

                  await _chatServices.sendMessage(
                      widget.receiverUserID, message);

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
  }

  Future<DocumentSnapshot?> _fetchServicio(String idEmpleo) async {
    try {
      DocumentSnapshot servicioDoc = await FirebaseFirestore.instance
          .collection('servicios')
          .doc(idEmpleo)
          .get();
      return servicioDoc;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching servicio: $e')),
        );
      }
      return null;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.receiverUserEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
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

                      if (userData != null) {
                        bool isActive = userData['isActive'] ?? false;

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
            const SizedBox(height: 5),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.receiverUserID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? userData =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  if (userData != null) {
                    bool isTyping = userData['isTyping'] ?? false;

                    if (isTyping) {
                      return const Center(
                        child: Text(
                          'escribiendo...',
                          style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
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
          widget.receiverUserID, _auth.currentUser!.uid),
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
          controller: _scrollController,
          children: snapshot.data!.docs
              .map<Widget>((document) => _buildMessageItem(document))
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
                      ? const EdgeInsets.only(right: 5.0)
                      : const EdgeInsets.only(left: 16.0),
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
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
