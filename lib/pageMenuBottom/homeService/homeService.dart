// ignore_for_file: unused_element, avoid_print, file_names, unused_local_variable, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/pageMenuBottom/profileService/profileService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'dart:async';

class HomePageService extends StatefulWidget {
  const HomePageService({Key? key}) : super(key: key);

  @override
  State<HomePageService> createState() => _HomePageServiceState();
}

class _HomePageServiceState extends State<HomePageService> {
  Map<String, double> userRatings = {};

  late final PageController _pageController;

  final StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();

  final StreamController<List<DocumentSnapshot>> _star =
      StreamController<List<DocumentSnapshot>>();

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirebase();
    _StarDataFromFirebase();
    _loadUserRatingsFromFirebase();
  }

  void _loadUserRatingsFromFirebase() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
            .collection('calificacion')
            .where('correo', isEqualTo: userId)
            .get();
        // Mapa para almacenar la suma total y la cantidad de documentos por ID de servicio
        Map<String, Map<String, dynamic>> ratingStats = {};

        for (QueryDocumentSnapshot ratingDoc in ratingSnapshot.docs) {
          String servicioId = ratingDoc['id'];
          double estrellas = ratingDoc['estrellas'];

          // Verifica si el ID del servicio ya existe en userRatings
          if (ratingStats.containsKey(servicioId)) {
            // Si existe, actualiza la suma total y la cantidad de documentos
            ratingStats[servicioId]!['sumaTotal'] += estrellas;
            ratingStats[servicioId]!['cantidadDocumentos'] += 1;
          } else {
            // Si no existe, crea una nueva entrada en el mapa
            ratingStats[servicioId] = {
              'sumaTotal': estrellas,
              'cantidadDocumentos': 1,
            };
          }
        }
        print('Resultados de la calificación:');
        ratingStats.forEach((key, value) {
          double media = value['sumaTotal'] / value['cantidadDocumentos'];
          print('ID de Servicio: $key, Media de Calificación: $media');
        });

        for (QueryDocumentSnapshot ratingDoc in ratingSnapshot.docs) {
          String servicioId = ratingDoc['id'];
          double estrellas = ratingDoc['estrellas'];
          userRatings[servicioId] = estrellas;
        }

        setState(() {});
      }
    } catch (e) {
      print('Error loading user ratings: $e');
    }
  }

  void _StarDataFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('calificacion').get();

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageController = PageController(viewportFraction: 0.8, keepPage: true);
  }

  @override
  void dispose() {
    _controller.close();
    _star.close();
    _pageController.dispose();
    super.dispose();
  }

  // Agrega la función buildCarousel aquí
  Widget buildCarousel(BuildContext context, List<DocumentSnapshot> servicios) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0,
        enableInfiniteScroll: true,
        autoPlay: true,
        viewportFraction: 0.8,
        autoPlayInterval:
            const Duration(seconds: 3), // Agrega esta línea para autoPlay
      ),
      items: servicios
          .map((servicio) {
            String titulo = servicio['titulo'];
            String contenido = servicio['contenido'];
            String idS = servicio['id'];
            return buildCuadro(context, titulo, contenido, idS);
          })
          .map((widget) => Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 6.0), // Ajusta el espacio entre los cuadros
                child: widget,
              ))
          .toList(),
    );
  }

  Widget buildCuadro(
      BuildContext context, String titulo, String contenido, String idS) {
    double mediaEstrellas = userRatings[idS] ?? 0.0;
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
                    initialRating: mediaEstrellas,
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
                    onRatingUpdate: (rating) async {
                      String? userId = FirebaseAuth.instance.currentUser?.uid;

                      if (userId != null) {
                        // Verificar si el documento ya existe
                        QuerySnapshot ratingSnapshot = await FirebaseFirestore
                            .instance
                            .collection('calificacion')
                            .where('correo', isEqualTo: userId)
                            .get();

                        print('1');
                        if (ratingSnapshot.docs.isNotEmpty) {
                          print('2');
                          DocumentSnapshot? ratingDoc;
                          try {
                            ratingDoc = ratingSnapshot.docs.firstWhere(
                              (doc) =>
                                  doc['id'] == idS && doc['correo'] == userId,
                            );
                          } catch (e) {
                            ratingDoc = null;
                          }

                          String calificacionId = ratingDoc?['id'] ?? '';
                          // Actualizar el documento existente con la nueva calificación
                          if (ratingDoc != null) {
                            print('3');
                            // El documento existe, actualizar solo las estrellas
                            await FirebaseFirestore.instance
                                .collection('calificacion')
                                .doc(ratingDoc.id)
                                .update({
                              'estrellas': rating,
                            });
                          } else {
                            print('4');
                            // El id no coincide, crear un nuevo documento
                            await FirebaseFirestore.instance
                                .collection('calificacion')
                                .doc() // Puedes mantener doc() si deseas un nuevo ID automático
                                .set({
                              'estrellas': rating,
                              'correo': userId,
                              'id': idS,
                            });
                          }
                        } else {
                          print('5');
                          // Crear un nuevo documento si no existe
                          await FirebaseFirestore.instance
                              .collection('calificacion')
                              .doc() // Puedes mantener doc() si deseas un nuevo ID automático
                              .set({
                            'estrellas': rating,
                            'correo': userId,
                            'id': idS,
                          });
                        }
                      }
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
        String idS = cuadro['id'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: buildCuadro(context, titulo, contenido, idS),
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
                      return const CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtienen los datos
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
