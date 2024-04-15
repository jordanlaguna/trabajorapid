// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/components/menuSlider/page_chat/page_home_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Profile(
        uid: 'uid',
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Profile extends StatelessWidget {
  const Profile({Key? key, required String uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      body: const SingleChildScrollView(
        child: ProfileScreen(),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _commentController = TextEditingController();

  bool showRatingSection = true;
  List<Comment> comments = [];

  String titulo = '';
  String contenido = '';
  String idS = '';
  String nombreDelPerfil = '';
  String correo = '';
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
    getComments().then((value) {
      setState(() {
        comments = value;
      });
    });
    getUserData('uid').then((userData) {
      if (userData != null) {
        // Aquí puedes actualizar el estado con los datos del usuario, por ejemplo:
        setState(() {
          nombreDelPerfil = userData['name'];
          correo = userData['email'];

          // Suponiendo que 'nombre' es un campo en tus datos de usuario
        });
      }
    });
    getUserData('uid').then((servicesSnapshot) {
      if (servicesSnapshot != null) {
        // Aquí puedes actualizar el estado con los datos del usuario, por ejemplo:
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
      DocumentSnapshot<Map<String, dynamic>> userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userData;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

// Función para obtener los servicios del usuario con el UID dado
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getUserServices(
      String uid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> servicesSnapshot =
          await FirebaseFirestore.instance
              .collection('servicios')
              .where('uid', isEqualTo: uid)
              .get();
      return servicesSnapshot.docs;
    } catch (e) {
      print('Error obteniendo servicios del usuario: $e');
      return [];
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

  @override
  Widget build(BuildContext context) {
    double mediaEstrellas = userRatings[idS] ?? 0.00;
    int nume = cantidadDocumentos[idS] ?? 0;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('URL_DE_TU_IMAGEN'),
          ),
          const SizedBox(height: 16),
          const Icon(
            Icons.circle,
            color: Colors.green,
            size: 10,
          ),
          Text(
            nombreDelPerfil,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            correo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            direccion,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
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
                            // Verificar si el documento ya existe
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

                              // Actualizar el documento existente con la nueva calificación
                              if (ratingDoc != null) {
                                print('3');
                                // El documento existe, actualizar solo las estrellas
                                await FirebaseFirestore.instance
                                    .collection('calificacionPerfil')
                                    .doc(ratingDoc.id)
                                    .update({
                                  'estrellas': rating,
                                });
                              } else {
                                print('4');
                                // El id no coincide, crear un nuevo documento
                                await FirebaseFirestore.instance
                                    .collection('calificacionPerfil')
                                    .doc() // Puedes mantener doc() si deseas un nuevo ID automático
                                    .set({
                                  'estrellas': rating,
                                  'uid': userId,
                                  'id': idS,
                                });
                              }
                            } else {
                              print('5');
                              // Crear un nuevo documento si no existe
                              await FirebaseFirestore.instance
                                  .collection('calificacionPerfil')
                                  .doc() // Puedes mantener doc() si deseas un nuevo ID automático
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
                  // show news comments list
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.3, // Altura máxima para la lista de comentarios
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(comments[index].userName),
                          subtitle: Text(comments[index].comment),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10, // Espacio para la barra de comentarios
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

  // add a new comment to Firestore
  Future<void> addComment(String comment) async {
    if (comment.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userName = user.displayName ?? '';
        String uid = user.uid;

        CollectionReference commentsCollection =
            FirebaseFirestore.instance.collection('comments');
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
        });
      } else {
        // the user is not logged in
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un comentario')),
      );
    }
  }

// update the comments list after adding a new comment
  Future<void> updateCommentsList() async {
    List<Comment> updatedComments = await getComments();
    setState(() {
      comments = updatedComments;
    });
  }
}

// get comments from Firestore and return as a list of Comment objects
Future<List<Comment>> getComments() async {
  List<Comment> comments = [];
  CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection('comments');
  QuerySnapshot querySnapshot = await commentsCollection.get();
  querySnapshot.docs.forEach((doc) {
    comments.add(Comment(
      userName: doc['userName'],
      comment: doc['comment'],
    ));
  });
  return comments;
}

class Comment {
  final String userName;
  final String comment;

  Comment({required this.userName, required this.comment});
}
