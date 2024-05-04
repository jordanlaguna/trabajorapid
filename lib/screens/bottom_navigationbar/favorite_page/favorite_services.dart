// ignore_for_file: unused_element, avoid_print, file_names, unused_local_variable, non_constant_identifier_names, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/profileService/profileService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<String?> getUserPhotoUrl(String uid) async {
    try {
      // Intenta obtener la URL de la foto del usuario desde la base de datos
      DocumentSnapshot<Map<String, dynamic>> userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Si la URL de la foto está disponible en la base de datos, úsala
      if (userData.exists && userData['photoURL'] != null) {
        return userData['photoURL'];
      } else {
        // Si la URL de la foto no está disponible en la base de datos, utiliza la foto de perfil de la autenticación
        return FirebaseAuth.instance.currentUser?.photoURL;
      }
    } catch (e) {
      print('Error obteniendo la URL de la foto del usuario: $e');
      return null;
    }
  }

  bool _isPressed = false;
  String titulo = "Nombre";

  Widget buildCuadro(
      BuildContext context,
      String titulo,
      String contenido,
      String idS,
      String tipoOferta,
      String direccion,
      String pago,
      String uid) {
    double mediaEstrellas = userRatings[idS] ?? 0.00;
    int nume = cantidadDocumentos[idS] ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 50, // Establece el ancho deseado
                        height: 50, // Establece la altura deseada
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            width: 50, // Ancho del contenedor interno
                            height: 50, // Altura del contenedor interno
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: FutureBuilder<String?>(
                                future: getUserPhotoUrl(uid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Icon(Icons.error_outline,
                                        size: 30,
                                        color: Colors.red); // Tamaño modificado
                                  } else if (snapshot.hasData) {
                                    return Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return const Icon(Icons.account_circle,
                                        size: 30); // Tamaño modificado
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight
                                        .bold, // Hace el texto en negrita
                                    fontSize:
                                        15.0, // Ajusta el tamaño de la fuente a 20 puntos
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
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
                                itemSize: 20,
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
                                            .collection('calificacion')
                                            .where('uid', isEqualTo: userId)
                                            .get();

                                    print('1');
                                    if (ratingSnapshot.docs.isNotEmpty) {
                                      print('2');
                                      DocumentSnapshot? ratingDoc;
                                      try {
                                        ratingDoc =
                                            ratingSnapshot.docs.firstWhere(
                                          (doc) =>
                                              doc['id'] == idS &&
                                              doc['uid'] == userId,
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
                              const SizedBox(width: 1.0),
                              Text('($nume)'),
                              const SizedBox(width: 5.0),
                              GestureDetector(
                                onTap: () async {
                                  _toggleLike(idS);
                                },
                                child: FutureBuilder<bool>(
                                  future: _isLiked(idS),
                                  // Llama a la función _isLiked
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
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: double.infinity, // Ocupa todo el ancho disponible
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          contenido.length > 38
                              ? '${contenido.substring(0, 35)}...'
                              : contenido,
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          '${tipoOferta.length > 35 ? '${tipoOferta.substring(0, 30)}...' : tipoOferta} - $pago ₡',
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          direccion.length > 38
                              ? '${direccion.substring(0, 35)}...'
                              : direccion,
                        ),
                        const SizedBox(height: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Profile(uid: uid, idS: idS),
                                  ),
                                );
                              },
                              child: Transform.scale(
                                scale: _isPressed
                                    ? 0.9
                                    : 1.0, // Reduce el tamaño cuando está presionado
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 0, 92, 252),
                                        Color.fromARGB(255, 86, 173, 255)
                                      ], // Colores del gradiente
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Información',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.touch_app,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTapDown: (_) => setState(() {
                                _isPressed =
                                    true; // Para la animación de escala
                              }),
                              onTapUp: (_) => setState(() {
                                _isPressed =
                                    false; // Para revertir la animación
                              }),
                              onTapCancel: () => setState(() {
                                _isPressed =
                                    false; // Asegura que el estado se resetee si la acción es cancelada
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        String uid = cuadro['uid'];
        final double pagoDouble = cuadro['pago']?.toDouble() ?? 0.0;
        final String pago = pagoDouble.toStringAsFixed(2);
        return SizedBox(
          height: 250, // Modificar la altura según sea necesario
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: buildCuadro(context, titulo, contenido, idS, tipoOferta,
                direccion, pago, uid),
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
      backgroundColor: const Color.fromARGB(255, 227, 242, 253),
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
