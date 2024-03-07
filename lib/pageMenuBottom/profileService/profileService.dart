// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<String> comments = [];
  bool showRatingSection =
      true; // Variable para alternar entre calificación y comentarios

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
              child: SizedBox(
                height: 200, // Ajusta la altura según sea necesario
                child: ListView.builder(
                  itemCount: comments.length + 1,
                  itemBuilder: (context, index) {
                    if (index < comments.length) {
                      return ListTile(
                        title: Text(comments[index]),
                        tileColor: const Color.fromARGB(255, 255, 255, 255),
                      );
                    } else {
                      // Ingresar nuevo comentario
                      return ListTile(
                        title: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu comentario',
                          ),
                        ),
                        tileColor: Colors.grey[200],
                        trailing: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            setState(() {
                              comments.add(_commentController.text);
                              _commentController.clear();
                            });
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

          const Divider(),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              // Acción al presionar el botón (puede ser redirigir a otro enlace, abrir una pantalla de edición, etc.).
            },
            child: const Text('Negociar'),
          ),
        ],
      ),
    );
  }
}
