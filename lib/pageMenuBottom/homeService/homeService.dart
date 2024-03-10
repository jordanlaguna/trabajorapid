import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/pageMenuBottom/profileService/profileService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Importa la librería del carrusel

class HomePageService extends StatefulWidget {
  const HomePageService({Key? key}) : super(key: key);

  @override
  _HomePageServiceState createState() => _HomePageServiceState();
}

class _HomePageServiceState extends State<HomePageService> {
  double userRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserRating();
  }

  Future<void> _fetchUserRating() async {
    // Obtén el ID del usuario actual
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Verifica si el usuario está autenticado
    if (userId != null) {
      // Consulta la calificación del usuario desde la colección "calificación" de Firebase
      DocumentSnapshot userRatingDoc = await FirebaseFirestore.instance
          .collection('calificación')
          .doc(userId)
          .get();

      // Verifica si el documento existe antes de obtener la calificación
      if (userRatingDoc.exists) {
        // Actualiza el estado con la calificación del usuario
        setState(() {
          userRating = userRatingDoc['estrellas'];
        });
      } else {
        // Si no hay una calificación previa, inicializa con 0.0
        setState(() {
          userRating = userRatingDoc['estrellas'];
        });
      }
    }
  }

  final PageController _pageController =
      PageController(viewportFraction: 0.8, keepPage: true);
  int currentPage = 0;

  void _configureAutoScroll(int itemCount) {
    _pageController.addListener(() {
      if (_pageController.page == _pageController.page!.toInt()) {
        Future.delayed(const Duration(seconds: 4), () {
          if (currentPage == itemCount - 1) {
            _pageController.animateToPage(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.bounceOut);
          } else {
            _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          }
        });
      }
    });
  }

  // Agrega la función buildCarousel aquí
  Widget buildCarousel(BuildContext context, List<DocumentSnapshot> servicios) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0,
        enableInfiniteScroll: true,
        autoPlay: true,
      ),
      items: servicios
          .map((servicio) {
            String titulo = servicio['titulo'];
            String contenido = servicio['contenido'];

            return buildCuadro(context, titulo, contenido);
          })
          .map((widget) => Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 6.0), // Ajusta el espacio entre los cuadros
                child: widget,
              ))
          .toList(),
    );
  }

  Widget buildCuadro(BuildContext context, String titulo, String contenido) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: 90.0,
              height: 90.0,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 3,
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
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemSize: 20,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      String? userId = FirebaseAuth.instance.currentUser?.uid;

                      if (userId != null) {
                        // Guardar la calificación en la colección "calificación" de Firebase

                        FirebaseFirestore.instance
                            .collection('calificacion')
                            .doc(userId)
                            .set({
                          'estrellas': rating,
                          'correo': userId,
                        });
                      }
                      setState(() {
                        userRating = rating;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(contenido),
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                  child: const Text('Presiona aquí'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCuadrosFromDatabase(
      BuildContext context, List<DocumentSnapshot> cuadros) {
    return Column(
      children: cuadros.map((cuadro) {
        String titulo = cuadro['titulo'];
        String contenido = cuadro['contenido'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: buildCuadro(context, titulo, contenido),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: const Text(
          'Ofertas de Servicios',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 249, 249, 249),
          ),
        ),
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
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Manejar la selección del menú
              print(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                'Más contratados',
                'Mejor calificados',
                'Más cerca',
                'Más nuevo'
              ].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Título
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Mejor calificado ⭐',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Carrusel de cuadros con información y fotos
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('servicios').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtienen los datos
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                List<QueryDocumentSnapshot> documentos = snapshot.data!.docs;

                return buildCarousel(
                    context, documentos); // Usa la función buildCarousel
              },
            ),
            // Indicador de página actual
            const SizedBox(height: 3.0),
            // Otro contenido del código existente
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance.collection('servicios').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    List<QueryDocumentSnapshot> documentos =
                        snapshot.data!.docs;

                    return buildCuadrosFromDatabase(context,
                        documentos); // Usa la función buildCuadrosFromDatabase
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    home: HomePageService(),
  ));
}
