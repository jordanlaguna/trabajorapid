// ignore_for_file: unused_element, avoid_print, file_names, unused_local_variable, non_constant_identifier_names, duplicate_ignore
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/profileService/profileService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
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
  // Obtener la ubicación actual del usuario

  @override
  void initState() {
    super.initState();
    // Fetch data from Firebase on initialization
    _fetchDataFromFirebase();
    _StarDataFromFirebase();
    _loadUserRatingsFromFirebase();
  }

  // Función para convertir grados a radianes
  double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

// Función para calcular la distancia entre dos puntos en la superficie de la Tierra utilizando la fórmula de Haversine
  double calcularDistancia(
    double latitudUsuario,
    double longitudUsuario,
    double latitudServicio,
    double longitudServicio,
  ) {
    const double radioTierra = 6371; // Radio de la Tierra en kilómetros

    double latitud1Rad = degreesToRadians(latitudUsuario);
    double longitud1Rad = degreesToRadians(longitudUsuario);
    double latitud2Rad = degreesToRadians(latitudServicio);
    double longitud2Rad = degreesToRadians(longitudServicio);

    double deltaLatitud = latitud2Rad - latitud1Rad;
    double deltaLongitud = longitud2Rad - longitud1Rad;

    double a = sin(deltaLatitud / 2) * sin(deltaLatitud / 2) +
        cos(latitud1Rad) *
            cos(latitud2Rad) *
            sin(deltaLongitud / 2) *
            sin(deltaLongitud / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distancia = radioTierra * c; // Distancia en kilómetros
    print(latitud1Rad);
    print(longitud1Rad);
    print(latitud2Rad);
    print(longitud2Rad);

    print(distancia);
    return distancia;
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
        _todosLosServicios = snapshot.docs;
        _serviciosFiltrados = _todosLosServicios;
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

  void _fetchRecentServices() async {
    DateTime oneDayAgoUtc =
        DateTime.now().toUtc().subtract(const Duration(days: 1));

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('servicios')
          .where('tipoServicio', isEqualTo: widget.servicio)
          .where('fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgoUtc))
          .orderBy('fecha',
              descending:
                  true) // Asegúrate de que este orden coincida con el índice.
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _serviciosFiltrados = snapshot.docs;
        });
        print("Servicios recientes cargados correctamente.");
      } else {
        print("No se encontraron servicios recientes.");
      }
    } catch (e) {
      print('Error al recuperar los servicios recientes: $e');
    }
  }

  Widget buildCarousel(BuildContext context, List<DocumentSnapshot> servicios) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 240,
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
            String uid = servicio['uid'];
            final double pagoDouble = servicio['pago']?.toDouble() ?? 0.0;
            final String pago = pagoDouble.toStringAsFixed(2);
            return buildCuadro(context, titulo, contenido, idS, tipoOferta,
                direccion, pago, uid);
          })
          .map((widget) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                child: widget,
              ))
          .toList(),
    );
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
                                builder: (context, photoSnapshot) {
                                  if (photoSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (photoSnapshot.hasError) {
                                    return const Icon(Icons.error_outline,
                                        size: 30, color: Colors.red);
                                  } else {
                                    if (photoSnapshot.hasData &&
                                        photoSnapshot.data!.isNotEmpty) {
                                      return Image.network(
                                        photoSnapshot.data!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      );
                                    } else {
                                      return const Icon(Icons.account_circle,
                                          size: 30);
                                    }
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
                                SizedBox(
                                  width: 190,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      titulo,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 210,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              contenido.length > 38
                                  ? '${contenido.substring(0, 35)}...'
                                  : contenido,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 1.0),
                        SizedBox(
                          width: 210,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              '${tipoOferta.length > 35 ? '${tipoOferta.substring(0, 30)}...' : tipoOferta} - $pago ₡',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 1.0),
                        SizedBox(
                          width: 210,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              direccion.length > 38
                                  ? '${direccion.substring(0, 35)}...'
                                  : direccion,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
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
                                scale: _isPressed ? 0.9 : 1.0,
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
                                      ],
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
          height: 240, // Modificar la altura según sea necesario
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: buildCuadro(context, titulo, contenido, idS, tipoOferta,
                direccion, pago, uid),
          ),
        );
      }).toList(),
    );
  }

  void showOffersMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ofertas'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ExpansionTile(
                  title: const Text('Ofertas'),
                  children: <Widget>[
                    ListTile(
                      title: const Text('Oferta de empleo'),
                      onTap: () {
                        Navigator.of(context).pop();

                        handleOfferSelection('Oferta de empleo');
                      },
                    ),
                    ListTile(
                      title: const Text('Oferta de servicio'),
                      onTap: () {
                        Navigator.of(context).pop();

                        handleOfferSelection('Oferta de servicio');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleOfferSelection(String offerType) {
    print("Inicio del filtrado por: $offerType");

    List<DocumentSnapshot> filteredServices = _servicios.where((service) {
      Map<String, dynamic> data = service.data() as Map<String, dynamic>;
      return data['tipoOferta'] == offerType;
    }).toList();

    print("Servicios filtrados: ${filteredServices.length}");

    setState(() {
      _servicios = filteredServices;
      tituloText = offerType;
    });
  }

  String tituloText = 'Todos';

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
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 249, 249, 249),
          ),
        ),
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
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(color: Colors.white),
            ),
            color: Colors.blue[50], // Un color más vivo
            elevation: 20.0,
            onSelected: (value) async {
              switch (value) {
                case 'Mejor calificados':
                  await _fetchDataFromFirebase();

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
                    tituloText = 'Mejor calificado ⭐';
                    _servicios = serviciosFiltrados;
                  });
                  break;
                case 'Más cerca':
                  await _fetchDataFromFirebase();
                  Position currentPosition =
                      await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                  double latitudUsuario = currentPosition.latitude;
                  double longitudUsuario = currentPosition.longitude;

                  // Iterar sobre los servicios y calcular la distancia
                  List<DocumentSnapshot> serviciosCercanos = [];
                  for (var servicio in _servicios) {
                    double latitudServicio = servicio['latitude'];
                    double longitudServicio = servicio['longitude'];

                    // Calcular la distancia utilizando la fórmula de Haversine
                    double distancia = calcularDistancia(latitudUsuario,
                        longitudUsuario, latitudServicio, longitudServicio);

                    // Si la distancia es menor que 22, añadir el servicio a la lista de servicios cercanos
                    if (distancia < 0.53) {
                      serviciosCercanos.add(servicio);
                    }
                  }

                  // Actualizar la interfaz de usuario con los servicios cercanos
                  setState(() {
                    tituloText = 'Más cerca';
                    _servicios = serviciosCercanos;
                  });
                  break;
                case 'Más nuevo':
                  await _fetchDataFromFirebase();
                  _fetchRecentServices();
                  setState(() {
                    tituloText = 'Más nuevo';
                  });
                  // Código para manejar la opción "Más nuevo"
                  break;
                case 'Ofertas':
                  await _fetchDataFromFirebase();
                  // ignore: use_build_context_synchronously
                  showOffersMenu(context);
                  // Código para manejar la opción "Todos"
                  break;
                case 'Todos':
                  await _fetchDataFromFirebase();
                  setState(() {
                    tituloText = 'Todos';
                  });
                  // Código para manejar la opción "Todos"
                  break;
                default:
                  await _fetchDataFromFirebase();
                  setState(() {
                    tituloText = 'Todos';
                  });
                  // Código para manejar otras opciones si es necesario
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                'Ofertas',
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
                  case 'Ofertas':
                    icon = Icons.expand_more;
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(icon,
                          color: Colors
                              .blue), // Color más llamativo para los iconos
                      const SizedBox(
                          width: 10), // Más espacio entre icono y texto
                      Text(choice),
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
              padding: const EdgeInsets.all(5.0),
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
                  const SizedBox(width: 5.0),

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
            const Divider(
              color: Colors.white,
              thickness: 3.0,
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
            const Divider(
              color: Colors.white,
              thickness: 3.0,
            ),
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

List<DocumentSnapshot> _todosLosServicios = [];
List<DocumentSnapshot> _serviciosFiltrados = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    home: HomePageService(servicio: 'tipoServicio'),
  ));
}
