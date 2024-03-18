// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/components/menuSlider/page_chat/page_home_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Profile(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

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
        centerTitle: true,
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

  @override
  void initState() {
    super.initState();
    getComments().then((value) {
      setState(() {
        comments = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Nombre del perfil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ubicación: Ciudad, País',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Biografía del perfil.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
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
              child: RatingBar.builder(
                initialRating: 4,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  // Puedes manejar la actualización de la calificación aquí
                },
              ),
            )
          else
            SingleChildScrollView(
              child: Column(
                children: [
                  // show news comments list
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(comments[index].userName),
                        subtitle: Text(comments[index].comment),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 200,
                  ),
                  const Divider(),
                  ListTile(
                    title: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu comentario',
                      ),
                    ),
                    tileColor: Colors.grey[200],
                    trailing: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        await addComment(_commentController.text);
                        _commentController.clear();
                      },
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
