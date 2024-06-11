import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/homeService/homeService.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<List<DocumentSnapshot>> _getServicios() async {
    try {
      // Primero intenta obtener los datos del caché
      final snapshot = await FirebaseFirestore.instance
          .collection('ofertasServicios')
          .get(const GetOptions(source: Source.cache));
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs;
      }
    } catch (e) {
      // Maneja cualquier error de caché
      print('Error obteniendo datos del caché: $e');
    }

    // Si no hay datos en caché o hay un error, obtén los datos del servidor
    final snapshot =
        await FirebaseFirestore.instance.collection('ofertasServicios').get();
    return snapshot.docs;
  }

  Widget _buildCarousel(
      BuildContext context, List<DocumentSnapshot> servicios) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 120.0,
        enableInfiniteScroll: true,
        autoPlay: true,
      ),
      items: servicios
          .map((servicio) {
            String titulo = servicio['titulo'];
            String contenido = servicio['contenido'];
            String icon = servicio['icon'];
            return _buildCuadro(context, titulo, contenido, icon);
          })
          .map((widget) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                child: widget,
              ))
          .toList(),
    );
  }

  Widget _buildCuadrosDesdeFirestore(
      BuildContext context, List<DocumentSnapshot> servicios) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: servicios.map((servicio) {
        String titulo = servicio['titulo'];
        String contenido = servicio['contenido'];
        String icon = servicio['icon'];
        return _buildCuadro(context, titulo, contenido, icon);
      }).toList(),
    );
  }

  Widget _buildCuadro(
      BuildContext context, String titulo, String contenido, String icon) {
    Map<String, IconData> iconos = {
      'spa': Icons.spa,
      'build': Icons.build,
      'kitchen': Icons.kitchen,
      'directions_car': Icons.directions_car,
      'format_paint': Icons.format_paint,
      'grass': Icons.grass,
      'cleaning_services': Icons.cleaning_services,
      'child_care': Icons.child_care,
      'construction': Icons.construction,
      'book': Icons.book
    };

    IconData iconData = iconos[icon] ?? Icons.error;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageService(servicio: titulo),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 2, 139, 252),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Icon(
                                  iconData,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: titulo.length > 10
                                    ? '${titulo.substring(0, 10)}...'
                                    : titulo,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: contenido.length > 30
                                ? '${contenido.substring(0, 28)}...'
                                : contenido,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue[50],
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _getServicios(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<DocumentSnapshot> servicios = snapshot.data!;
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCarousel(context, servicios),
                      const SizedBox(height: 10.0),
                      const Text(
                        "Servicios",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                        thickness: 2.0,
                      ),
                      _buildCuadrosDesdeFirestore(context, servicios),
                      const SizedBox(height: 20.0)
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
