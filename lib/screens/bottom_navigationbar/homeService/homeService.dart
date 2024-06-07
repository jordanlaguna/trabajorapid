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

import 'package:trabajorapid/screens/menuSlider/drawer/navbar.dart';

class HomePageService extends StatefulWidget {
  final String servicio;

  const HomePageService({Key? key, required this.servicio}) : super(key: key);
  @override
  State<HomePageService> createState() => _HomePageServiceState();
}

class _HomePageServiceState extends State<HomePageService> {
  Map<String, double> userRatings = {};
  Map<String, int> cantidadDocumentos = {};
  List<DocumentSnapshot> _servicios = [];

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

  double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  double calcularDistancia(
    double latitudUsuario,
    double longitudUsuario,
    double latitudServicio,
    double longitudServicio,
  ) {
    const double radioTierra = 6371;

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

    double distancia = radioTierra * c;
    return distancia;
  }

  void _loadUserRatingsFromFirebase() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        QuerySnapshot ratingSnapshot =
            await FirebaseFirestore.instance.collection('calificacion').get();

        Map<String, Map<String, dynamic>> ratingStats = {};

        for (QueryDocumentSnapshot ratingDoc in ratingSnapshot.docs) {
          String servicioId = ratingDoc['id'];
          double estrellas = (ratingDoc['estrellas'] as num).toDouble();

          if (ratingStats.containsKey(servicioId)) {
            ratingStats[servicioId]!['sumaTotal'] += estrellas;
            ratingStats[servicioId]!['cantidadDocumentos'] += 1;
          } else {
            ratingStats[servicioId] = {
              'sumaTotal': estrellas,
              'cantidadDocumentos': 1,
            };
          }
        }

        setState(() {
          cantidadDocumentos = ratingStats
              .map((key, value) => MapEntry(key, value['cantidadDocumentos']));
          userRatings = ratingStats.map((key, value) =>
              MapEntry(key, value['sumaTotal'] / value['cantidadDocumentos']));
        });
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

  Future<void> _fetchDataFromFirebase() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('servicios')
            .where('tipoServicio', isEqualTo: widget.servicio)
            .where('Disponibilidad', isEqualTo: 'Activo')
            .where('Administrador', isEqualTo: 'Aceptado')
            .get();

        setState(() {
          _servicios =
              snapshot.docs.where((doc) => doc['uid'] != userId).toList();
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<DocumentSnapshot> _filtrarServiciosPorTipo(String tipo) {
    return _servicios.where((cuadro) {
      return cuadro['tipoServicio'] == tipo;
    }).toList();
  }

  void _toggleLike(String servicioId) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('likes')
            .doc(userId)
            .collection('servicios')
            .doc(servicioId)
            .get();

        if (doc.exists) {
          await FirebaseFirestore.instance
              .collection('likes')
              .doc(userId)
              .collection('servicios')
              .doc(servicioId)
              .delete();
        } else {
          await FirebaseFirestore.instance
              .collection('likes')
              .doc(userId)
              .collection('servicios')
              .doc(servicioId)
              .set({'liked': true});
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
          .orderBy('fecha', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {});
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
        height: 280,
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

            // Validar si los campos existen antes de acceder a ellos
            Map<String, dynamic>? data =
                servicio.data() as Map<String, dynamic>?;
            String experiencia =
                (data != null && data.containsKey('experiencia'))
                    ? data['experiencia'] ?? ''
                    : '';
            String requerimientos =
                (data != null && data.containsKey('requerimientos'))
                    ? data['requerimientos'] ?? ''
                    : '';

            List<dynamic> fotos = [];
            if (data != null && data.containsKey('fotos')) {
              fotos = data['fotos'];
            }

            return buildCuadro(context, titulo, contenido, idS, tipoOferta,
                direccion, pago, uid, fotos, experiencia, requerimientos);
          })
          .map((widget) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                child: widget,
              ))
          .toList(),
    );
  }

  String titulo = "Nombre";

  Widget buildCuadro(
    BuildContext context,
    String titulo,
    String contenido,
    String idS,
    String tipoOferta,
    String direccion,
    String pago,
    String uid,
    List<dynamic> fotos,
    String experiencia,
    String requerimientos,
  ) {
    double mediaEstrellas = userRatings[idS] ?? 0.00;
    int nume = cantidadDocumentos[idS] ?? 0;

    List<dynamic> fotosValidas = fotos.isNotEmpty ? fotos : [];

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
              offset: const Offset(0, 3),
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
                          width: 50,
                          height: 50,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              width: 50,
                              height: 50,
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
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  itemSize: 20,
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
                                              .collection('calificacion')
                                              .where('uid', isEqualTo: userId)
                                              .get();

                                      if (ratingSnapshot.docs.isNotEmpty) {
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

                                        if (ratingDoc != null) {
                                          await FirebaseFirestore.instance
                                              .collection('calificacion')
                                              .doc(ratingDoc.id)
                                              .update({'estrellas': rating});
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('calificacion')
                                              .doc()
                                              .set({
                                            'estrellas': rating,
                                            'uid': userId,
                                            'id': idS,
                                          });
                                        }
                                      } else {
                                        await FirebaseFirestore.instance
                                            .collection('calificacion')
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
                                const SizedBox(width: 1.0),
                                Text('($nume)'),
                                const SizedBox(width: 5.0),
                                GestureDetector(
                                  onTap: () async {
                                    _toggleLike(idS);
                                  },
                                  child: FutureBuilder<bool>(
                                    future: _isLiked(idS),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else {
                                        if (snapshot.hasData &&
                                            snapshot.data!) {
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Muestra la experiencia o los requerimientos según el tipo de oferta
                              if (tipoOferta == 'Oferta de servicio' &&
                                  experiencia.isNotEmpty) ...[
                                const SizedBox(height: 5.0),
                                SizedBox(
                                  width: 210,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Experiencia: $experiencia',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ] else if (tipoOferta == 'Oferta de empleo' &&
                                  requerimientos.isNotEmpty) ...[
                                const SizedBox(height: 5.0),
                                SizedBox(
                                  width: 210,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Requerimientos: $requerimientos',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _showPhotosModal(context, fotosValidas);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.photo,
                                            size: 16, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Fotos',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Profile(
                                            uid: uid,
                                            idS: idS,
                                            contenido: contenido,
                                            pago: pago,
                                            tipoOferta: tipoOferta,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.info,
                                            size: 16, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Información',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
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

        // Validar si los campos existen antes de acceder a ellos
        Map<String, dynamic>? data = cuadro.data() as Map<String, dynamic>?;
        String experiencia = (data != null && data.containsKey('experiencia'))
            ? data['experiencia'] ?? ''
            : '';
        String requerimientos =
            (data != null && data.containsKey('requerimientos'))
                ? data['requerimientos'] ?? ''
                : '';

        List<dynamic> fotos = [];
        if (data != null && data.containsKey('fotos')) {
          fotos = data['fotos'];
        }

        return SizedBox(
          height: 280,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: buildCuadro(context, titulo, contenido, idS, tipoOferta,
                direccion, pago, uid, fotos, experiencia, requerimientos),
          ),
        );
      }).toList(),
    );
  }

  void _showPhotosModal(BuildContext context, List<dynamic> fotos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fotos de la oferta'),
          content: fotos.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: fotos.map((fotoUrl) {
                      print(
                          'Photo URL: $fotoUrl'); // Imprimir la URL en la consola para verificar
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Image.network(
                          fotoUrl,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Text('No se pudo cargar la imagen');
                          },
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const Text('No hay fotos disponibles.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
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
            color: Colors.blue[50],
            elevation: 20.0,
            onSelected: (value) async {
              switch (value) {
                case 'Mejor calificados':
                  await _fetchDataFromFirebase();

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

                  List<DocumentSnapshot> serviciosFiltrados = [];
                  for (var servicio in servicios) {
                    double mediaEstrellas = userRatings[servicio['id']] ?? 0.00;
                    if (mediaEstrellas >= 3.0) {
                      serviciosFiltrados.add(servicio);
                    }
                  }

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

                  List<DocumentSnapshot> serviciosCercanos = [];
                  for (var servicio in _servicios) {
                    double latitudServicio = servicio['latitude'];
                    double longitudServicio = servicio['longitude'];

                    double distancia = calcularDistancia(latitudUsuario,
                        longitudUsuario, latitudServicio, longitudServicio);

                    if (distancia < 0.53) {
                      serviciosCercanos.add(servicio);
                    }
                  }

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
                  break;
                case 'Ofertas':
                  await _fetchDataFromFirebase();
                  showOffersMenu(context);
                  break;
                case 'Todos':
                  await _fetchDataFromFirebase();
                  setState(() {
                    tituloText = 'Todos';
                  });
                  break;
                default:
                  await _fetchDataFromFirebase();
                  setState(() {
                    tituloText = 'Todos';
                  });
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
                      Icon(icon, color: Colors.blue),
                      const SizedBox(width: 10),
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
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tituloText,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Center(),
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
            if (serviciosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No se encontraron servicios disponibles.',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 3.0),
            const Divider(
              color: Colors.white,
              thickness: 3.0,
            ),
            if (serviciosFiltrados.isNotEmpty)
              buildCuadrosFromDatabase(context, serviciosFiltrados),
            const SizedBox(height: 3.0),
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
