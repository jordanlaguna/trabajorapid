// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/screens/menuSlider/page_chat/page_home_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Profile(
        uid: 'uid',
        idS: 'idS',
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Profile extends StatelessWidget {
  final String uid;
  final String idS;

  const Profile({Key? key, required this.uid, required this.idS})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
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
      ),
      body: SingleChildScrollView(
        child: ProfileScreen(
          uid: uid,
          idS: idS,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String uid;
  final String idS;

  const ProfileScreen({Key? key, required this.uid, required this.idS})
      : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _commentController = TextEditingController();
  // Define uid as a property

  bool showRatingSection = true;
  List<Comment> comments = [];

  String titulo = '';
  String contenido = '';
  String idS = '';
  String name = '';
  String email = '';
  String direccion = '';

  Map<String, double> userRatings = {};
  Map<String, int> cantidadDocumentos = {};
  final StreamController<List<DocumentSnapshot>> _star =
      StreamController<List<DocumentSnapshot>>();

  // Stream controllers for fetching data
  final StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();

  @override
  void initState() {
    super.initState();
    getComments(widget.idS).then((value) {
      setState(() {
        comments = value;
      });
    });
    getUserData(widget.uid).then((userData) {
      if (userData != null) {
        setState(() {
          email = userData['email'];
          name = userData['name'];
          // Suponiendo que 'nombre' es un campo en tus datos de usuario
        });
      }
    });

    // Obtener los datos de los servicios del usuario utilizando las variables uid e idS reales
    getUserServices(widget.uid, widget.idS).then((servicesSnapshot) {
      if (servicesSnapshot != null) {
        setState(() {
          direccion = servicesSnapshot['direccion'];

          // Suponiendo que 'nombre' es un campo en tus datos de usuario
        });
      }
    });
    _fetchDataFromFirebase();
    _StarDataFromFirebase();
    _loadUserRatingsFromFirebase();
  }

  void _loadUserRatingsFromFirebase() async {
    try {
      // Get the current user's ID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Fetch ratings data from Firestore
        QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
            .collection('calificacionPerfil')
            .get();

        // Map to store total sum and document count per service ID
        Map<String, Map<String, dynamic>> ratingStats = {};

        // Loop through each document in the ratings collection
        for (QueryDocumentSnapshot ratingDoc in ratingSnapshot.docs) {
          // Extract service ID and stars rating
          String servicioId = ratingDoc['id'];
          double estrellas = (ratingDoc['estrellas'] as num).toDouble();

          // Check if the service ID exists in ratingStats
          if (ratingStats.containsKey(servicioId)) {
            // If it exists, update the total sum and document count
            ratingStats[servicioId]!['sumaTotal'] += estrellas;
            ratingStats[servicioId]!['cantidadDocumentos'] += 1;
          } else {
            // If it doesn't exist, create a new entry in the map
            ratingStats[servicioId] = {
              'sumaTotal': estrellas,
              'cantidadDocumentos': 1,
            };
          }
        }
        // Update the document count in the state
        setState(() {
          cantidadDocumentos = ratingStats
              .map((key, value) => MapEntry(key, value['cantidadDocumentos']));
        });

        // Output rating results to the console
        print('Resultados de la calificación:');
        ratingStats.forEach((key, value) {
          double media = value['sumaTotal'] / value['cantidadDocumentos'];
          int nume = value['cantidadDocumentos'];
          print(
              'ID de Servicio: $key, Media de Calificación: $media, cantidad: $nume');
        });
        // Update userRatings map with the average ratings
        for (QueryDocumentSnapshot ratingDoc in ratingSnapshot.docs) {
          String servicioId = ratingDoc['id'];
          double estrellas = (ratingDoc['estrellas'] as num).toDouble();
          userRatings[servicioId] = estrellas;
        }
        // Update the state with the updated user ratings and document counts
        setState(() {
          userRatings = ratingStats.map((key, value) =>
              MapEntry(key, value['sumaTotal'] / value['cantidadDocumentos']));
          cantidadDocumentos = ratingStats
              .map((key, value) => MapEntry(key, value['cantidadDocumentos']));
        });
      }
    } catch (e) {
      print('Error loading user ratings: $e');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserData(
      String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.uid)
          .get();
      return userData;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserServices(
      String uid, String id) async {
    try {
      var servicesSnapshot = await FirebaseFirestore.instance
          .collection('servicios')
          .where('uid', isEqualTo: widget.uid)
          .where('id', isEqualTo: widget.idS)
          .get();

      if (servicesSnapshot.docs.isNotEmpty) {
        return servicesSnapshot.docs.first
            as DocumentSnapshot<Map<String, dynamic>>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  // ignore: non_constant_identifier_names
  void _StarDataFromFirebase() async {
    try {
      // Fetches data (snapshot) from the 'calificacion' collection in Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('calificacionPerfil')
          .get();

      // Adds the snapshot documents to the '_star' stream controller
      _star.add(snapshot.docs);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _fetchDataFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('servicios').get();

      _controller.add(snapshot.docs);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<String?> getUserPhotoUrl(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userData.exists && userData['photoURL'] != null) {
        return userData['photoURL'];
      } else {
        return FirebaseAuth.instance.currentUser?.photoURL;
      }
    } catch (e) {
      print('Error obteniendo la URL de la foto del usuario: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double mediaEstrellas = userRatings[idS] ?? 0.00;
    int nume = cantidadDocumentos[idS] ?? 0;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: FutureBuilder<String?>(
                  future: getUserPhotoUrl(widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error_outline,
                          size: 150, color: Colors.red);
                    } else if (snapshot.hasData) {
                      return Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const Icon(Icons.account_circle, size: 150);
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Icon(
            Icons.circle,
            color: Colors.green,
            size: 10,
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 14),
          Text(
            direccion,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 16),
          const Divider(),

          ToggleButtons(
            isSelected: [showRatingSection, !showRatingSection],
            onPressed: (int index) {
              setState(() {
                showRatingSection = index == 0;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 19),
                child: Text('Calificación'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 19),
                child: Text('Comentarios'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sección de calificación o comentarios según la elección
          if (showRatingSection)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: mediaEstrellas,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemSize: 45,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) async {
                          String? userId =
                              FirebaseAuth.instance.currentUser?.uid;

                          if (userId != null) {
                            QuerySnapshot ratingSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('calificacionPerfil')
                                    .where('uid', isEqualTo: userId)
                                    .get();

                            print('1');
                            if (ratingSnapshot.docs.isNotEmpty) {
                              print('2');
                              DocumentSnapshot? ratingDoc;
                              try {
                                ratingDoc = ratingSnapshot.docs.firstWhere(
                                  (doc) =>
                                      doc['id'] == idS && doc['uid'] == userId,
                                );
                              } catch (e) {
                                ratingDoc = null;
                              }

                              if (ratingDoc != null) {
                                print('3');
                                await FirebaseFirestore.instance
                                    .collection('calificacionPerfil')
                                    .doc(ratingDoc.id)
                                    .update({
                                  'estrellas': rating,
                                });
                              } else {
                                print('4');
                                await FirebaseFirestore.instance
                                    .collection('calificacionPerfil')
                                    .doc()
                                    .set({
                                  'estrellas': rating,
                                  'uid': userId,
                                  'id': idS,
                                });
                              }
                            } else {
                              print('5');
                              await FirebaseFirestore.instance
                                  .collection('calificacionPerfil')
                                  .doc()
                                  .set({
                                'estrellas': rating,
                                'uid': userId,
                                'id': idS,
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 10.0),
                      Text('($nume)'),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(contenido),
                ],
              ),
            )
          else
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final isCurrentUser =
                            FirebaseAuth.instance.currentUser?.uid ==
                                comment.uid;
                        return ChatBubble(
                          userName: comment.userName,
                          comment: comment.comment,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListTile(
                      title: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu comentario',
                          )),
                      tileColor: Colors.grey[200],
                      trailing: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          await addComment(_commentController.text);
                          _commentController.clear();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PageChat()),
              );
            },
            child: const Text('Negociar'),
          ),
        ],
      ),
    );
  }

  Future<void> addComment(String comment) async {
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un comentario')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, inicia sesión para comentar')),
      );
      return;
    }

    String userName = user.displayName ?? '';
    String uid = user.uid;
    String serviceId = widget.idS;

    DocumentReference serviceDoc =
        FirebaseFirestore.instance.collection('serviceComments').doc(serviceId);

    DocumentSnapshot serviceSnapshot = await serviceDoc.get();
    if (!serviceSnapshot.exists) {
      await serviceDoc.set({
        'uid': serviceId,
      });
    }

    CollectionReference commentsCollection = serviceDoc.collection('comments');

    await commentsCollection.add({
      'uid': uid,
      'userName': userName,
      'comment': comment,
      'timestamp': DateTime.now(),
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario agregado')),
      );
      updateCommentsList();
    }).catchError((error) {
      print("Error al guardar el comentario: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar comentario: $error')),
      );
    });
  }

  Future<void> updateCommentsList() async {
    List<Comment> updatedComments = await getComments(widget.idS);
    setState(() {
      comments = updatedComments;
    });
  }
}

int _limit = 10;
// ignore: unused_element
DocumentSnapshot? _lastDocument;

Future<List<Comment>> getComments(String serviceId) async {
  Query query = FirebaseFirestore.instance
      .collection('serviceComments')
      .doc(serviceId)
      .collection('comments')
      .orderBy('timestamp', descending: true)
      .limit(_limit);

  QuerySnapshot commentSnapshot = await query.get();
  _lastDocument =
      commentSnapshot.docs.isNotEmpty ? commentSnapshot.docs.last : null;

  List<Comment> comments = commentSnapshot.docs
      .map((doc) => Comment(
            userName: doc['userName'],
            comment: doc['comment'],
            uid: doc['uid'],
          ))
      .toList();

  return comments;
}

class Comment {
  final String userName;
  final String comment;
  final String uid;

  Comment({required this.userName, required this.comment, required this.uid});
}

class ChatBubble extends StatelessWidget {
  final String userName;
  final String comment;
  final bool isCurrentUser;

  const ChatBubble({
    Key? key,
    required this.userName,
    required this.comment,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft:
          isCurrentUser ? const Radius.circular(16) : const Radius.circular(0),
      bottomRight:
          isCurrentUser ? const Radius.circular(0) : const Radius.circular(16),
    );

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[300] : Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              comment,
              style: TextStyle(
                fontSize: 14,
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
