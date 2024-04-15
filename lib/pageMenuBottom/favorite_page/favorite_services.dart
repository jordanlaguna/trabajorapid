// ignore_for_file: unused_element, avoid_print, file_names, unused_local_variable, non_constant_identifier_names, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/pageMenuBottom/profileService/profileService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'dart:async';

class FavoritePageService extends StatefulWidget {
  final String servicio;

  const FavoritePageService({Key? key, required this.servicio})
      : super(key: key);
  @override
  State<FavoritePageService> createState() => _FavoritePageService();
}

class _FavoritePageService extends State<FavoritePageService> {
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

        ratingStats.forEach((key, value) {
          double media = value['sumaTotal'] / value['cantidadDocumentos'];
          int nume = value['cantidadDocumentos'];
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

      List<DocumentSnapshot> likedServicios = [];

      // Filtrar los servicios que tienen 'Me gusta'
      for (var servicio in snapshot.docs) {
        String servicioId = servicio.id;
        bool isLiked = await _isLiked(servicioId);
        if (isLiked) {
          likedServicios.add(servicio);
        }
      }

      setState(() {
        _servicios = likedServicios;
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
              .set({'liked': true});
        }

        // Actualizar el estado después de que se complete la operación
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
                        _toggleLike(idS);
                        // Actualizar el estado después de que se complete la operación
                      },
                      child: FutureBuilder<bool>(
                        future: _isLiked(idS),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            if (snapshot.hasData && snapshot.data!) {
                              return const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              );
                            } else {
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
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
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
      body: serviciosFiltrados.isNotEmpty
          ? buildCuadrosFromDatabase(context, serviciosFiltrados)
          : const Center(
              child: Text('No hay servicios con "Me gusta"'),
            ),
    );
  }
}
