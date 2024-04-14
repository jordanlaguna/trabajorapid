// ignore_for_file: unused_element, avoid_print, file_names, unused_local_variable, non_constant_identifier_names, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/pageMenuBottom/profileService/profileService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'dart:async';

class HomePageService extends StatefulWidget {
  final String servicio;

  const HomePageService({Key? key, required this.servicio}) : super(key: key);
  @override
  State<HomePageService> createState() => _HomePageServiceState();
}

class _HomePageServiceState extends State<HomePageService> {
  // Maps to store user ratings and document counts
  Map<String, double> userRatings = {};
  Map<String, int> cantidadDocumentos = {};
  List<DocumentSnapshot> _servicios = [];
  // Page controller for carousel
  late final PageController _pageController;
  // Stream controllers for fetching data
  final StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();

  final StreamController<List<DocumentSnapshot>> _star =
      StreamController<List<DocumentSnapshot>>();

  @override
  void initState() {
    super.initState();
    // Fetch data from Firebase on initialization
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
        QuerySnapshot ratingSnapshot =
            await FirebaseFirestore.instance.collection('calificacion').get();

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

  void _StarDataFromFirebase() async {
    try {
      // Fetches data (snapshot) from the 'calificacion' collection in Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('calificacion').get();

      // Adds the snapshot documents to the '_star' stream controller
      _star.add(snapshot.docs);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _fetchDataFromFirebase() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('servicios')
          .where('tipoServicio',
              isEqualTo: widget.servicio) // Filtrar por el tipo de servicio
          .get();

      setState(() {
        _servicios = snapshot.docs;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<DocumentSnapshot> _filtrarServiciosPorTipo(String tipo) {
    List<DocumentSnapshot> serviciosFiltrados = [];

    for (var cuadro in _servicios) {
      String tipoServicio = cuadro['tipoServicio'];

      if (tipoServicio == tipo) {
        serviciosFiltrados.add(cuadro);
      }
    }

    return serviciosFiltrados;
  }

  void _toggleLike(String servicioId) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Verificar si el usuario ya le dio "Me gusta" al servicio
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('likes')
            .doc(userId)
            .collection('servicios')
            .doc(servicioId)
            .get();

        if (doc.exists) {
          // Si el usuario ya le dio "Me gusta", eliminar el like
          await FirebaseFirestore.instance
              .collection('likes')
              .doc(userId)
              .collection('servicios')
              .doc(servicioId)
              .delete();
        } else {
          // Si el usuario no le ha dado "Me gusta", agregar el like
          await FirebaseFirestore.instance
              .collection('likes')
              .doc(userId)
              .collection('servicios')
              .doc(servicioId)
              .set({
            'liked': true,
          });
        }
        setState(() {});
      }
    } catch (e) {
      print('Error al alternar "Me gusta": $e');
    }
  }

  Future<bool> _isLiked(String servicioId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Verificar si el usuario le ha dado "Me gusta" al servicio
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('likes')
          .doc(userId)
          .collection('servicios')
          .doc(servicioId)
          .get();
      return doc.exists;
    }
    return false;
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

  Widget buildCarousel(BuildContext context, List<DocumentSnapshot> servicios) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        enableInfiniteScroll: true,
        autoPlay: true,
        viewportFraction: 0.8,
        autoPlayInterval: const Duration(seconds: 4),
      ),
      items: servicios
          .map((servicio) {
            String titulo = servicio['titulo'];
            String contenido = servicio['contenido'];
            String idS = servicio['id'];
            String tipoOferta = servicio['tipoOferta'];
            String direccion = servicio['direccion'];
            final double pagoDouble = servicio['pago']?.toDouble() ?? 0.0;
            final String pago = pagoDouble.toStringAsFixed(2);
            return buildCuadro(
                context, titulo, contenido, idS, tipoOferta, direccion, pago);
          })
          .map((widget) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                child: widget,
              ))
          .toList(),
    );
  }

  Widget buildCuadro(BuildContext context, String titulo, String contenido,
      String idS, String tipoOferta, String direccion, String pago) {
    double mediaEstrellas = userRatings[idS] ?? 0.00;
    int nume = cantidadDocumentos[idS] ?? 0;
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
          const SizedBox(width: 12.0),
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
                Row(
                  children: [
                    RatingBar.builder(
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
                                'uid': userId,
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
                Text(
                  contenido.length > 20
                      ? '${contenido.substring(0, 5)}...'
                      : contenido,
                ),
                const SizedBox(height: 5.0),
                Text(
                  tipoOferta.length > 20
                      ? '${tipoOferta.substring(0, 20)}...'
                      : tipoOferta,
                ),
                const SizedBox(height: 5.0),
                Text(
                  direccion.length > 20
                      ? '${direccion.substring(0, 20)}...'
                      : direccion,
                ),
                const SizedBox(height: 5.0),
                Text('$pago ₡'),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _toggleLike(
                            idS); // Espera a que se complete la operación asincrónica
                        // Actualiza el estado después de que se complete la operación
                      },
                      child: FutureBuilder<bool>(
                        future: _isLiked(idS), // Llama a la función _isLiked
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Muestra un indicador de carga mientras se espera la respuesta
                            return const CircularProgressIndicator();
                          } else {
                            if (snapshot.hasData && snapshot.data!) {
                              // Si hay datos y el resultado es verdadero, muestra el icono en rojo
                              return const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              );
                            } else {
                              // De lo contrario, muestra el icono en gris
                              return const Icon(
                                Icons.favorite_border,
                                color: Colors.grey,
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Profile()),
                        );
                      },
                      child: const Text('Presiona aquí'),
                    ),
                  ],
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
        String tipoOferta = cuadro['tipoOferta'];
        String direccion = cuadro['direccion'];
        final double pagoDouble = cuadro['pago']?.toDouble() ?? 0.0;
        final String pago = pagoDouble.toStringAsFixed(2);
        return SizedBox(
          height: 250, // Modificar la altura según sea necesario
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: buildCuadro(
                context, titulo, contenido, idS, tipoOferta, direccion, pago),
          ),
        );
      }).toList(),
    );
  }

  String tituloText = 'Todos';

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> serviciosFiltrados =
        _filtrarServiciosPorTipo(widget.servicio);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: Text(
          widget.servicio,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 249, 249, 249),
          ),
        ),
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
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 'Mejor calificados':
                  tituloText = 'Mejor calificado ⭐';
                  // Obtener los servicios y ordenarlos por media de estrellas de mayor a menor
                  List<DocumentSnapshot> servicios = await FirebaseFirestore
                      .instance
                      .collection('servicios')
                      .get()
                      .then((snapshot) => snapshot.docs);

                  servicios.sort((a, b) {
                    double mediaEstrellasA = userRatings[a['id']] ?? 0.00;
                    double mediaEstrellasB = userRatings[b['id']] ?? 0.00;
                    return mediaEstrellasB.compareTo(mediaEstrellasA);
                  });

                  // Filtrar los servicios para guardar solo los que tienen 3 estrellas o más
                  List<DocumentSnapshot> serviciosFiltrados = [];
                  for (var servicio in servicios) {
                    double mediaEstrellas = userRatings[servicio['id']] ?? 0.00;
                    if (mediaEstrellas >= 3.0) {
                      serviciosFiltrados.add(servicio);
                    }
                  }

                  // Actualizar la UI con los servicios filtrados
                  setState(() {
                    _servicios = serviciosFiltrados;
                  });
                  break;
                case 'Más cerca':
                  tituloText = 'Más cerca';
                  setState(() {
                    _servicios;
                  });
                  // Código para manejar la opción "Más cerca"
                  break;
                case 'Más nuevo':
                  tituloText = 'Más nuevo';
                  setState(() {
                    _servicios;
                  });
                  // Código para manejar la opción "Más nuevo"
                  break;
                case 'Todos':
                  tituloText = 'Todos';
                  setState(() {
                    _servicios;
                  });
                  // Código para manejar la opción "Todos"
                  break;
                default:
                  tituloText = 'Todos';
                  setState(() {
                    _servicios;
                  });
                  // Código para manejar otras opciones si es necesario
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                'Más contratados',
                'Mejor calificados',
                'Más cerca',
                'Más nuevo',
                'Todos'
              ].map((String choice) {
                // Agregar iconos después de cada opción en el menú emergente
                IconData? icon;

                switch (choice) {
                  case 'Más contratados':
                    icon = Icons.thumb_up;
                    break;
                  case 'Mejor calificados':
                    icon = Icons.star;
                    break;
                  case 'Más cerca':
                    icon = Icons.location_on;
                    break;
                  case 'Más nuevo':
                    icon = Icons.new_releases;
                    break;
                  case 'Todos':
                    icon = Icons.list;
                    break;
                  default:
                    icon = null;
                }

                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      // Texto de la opción del menú
                      Text(choice),
                      const SizedBox(width: 8),
                      // Icono asociado a la opción del menú
                      if (icon != null) Icon(icon, color: Colors.black),
                    ],
                  ),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Texto del título
                  Text(
                    tituloText,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Espaciador para centrar el contenido
                  const Center(),
                  // Icono asociado al texto del título
                  if (tituloText == 'Más contratados')
                    const Icon(Icons.thumb_up, color: Colors.black),
                  if (tituloText == 'Mejor calificados')
                    const Icon(Icons.star, color: Colors.black),
                  if (tituloText == 'Más cerca')
                    const Icon(Icons.location_on, color: Colors.black),
                  if (tituloText == 'Más nuevo')
                    const Icon(Icons.new_releases, color: Colors.black),
                  if (tituloText == 'Todos')
                    const Icon(Icons.list, color: Colors.black),
                ],
              ),
            ),
            buildCarousel(context, serviciosFiltrados),
            // Carrusel de cuadros con información y fotos
            if (serviciosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No se encontraron servicios disponibles.',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            // Si no está vacía, mostrar los cuadros con información
            const SizedBox(height: 3.0),
            if (serviciosFiltrados.isNotEmpty)
              buildCuadrosFromDatabase(context, serviciosFiltrados),
            // Indicador de página actual
            const SizedBox(height: 3.0),
            // Otro contenido del código existente
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
    home: HomePageService(servicio: 'tipoServicio'),
  ));
}
