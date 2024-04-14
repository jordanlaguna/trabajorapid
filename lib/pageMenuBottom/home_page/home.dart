import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/pageMenuBottom/homeService/homeService.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<List<DocumentSnapshot>> _getServicios() async {
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
                margin: const EdgeInsets.symmetric(
                    horizontal: 6.0), // Ajusta el espacio entre los cuadros
                child: widget,
              ))
          .toList(),
    );
  }

  Widget _buildCuadrosDesdeFirestore(
      BuildContext context, List<DocumentSnapshot> servicios) {
    return GridView.count(
      crossAxisCount: 2, // Esto dividirá los elementos en dos columnas
      crossAxisSpacing: 10.0, // Espacio entre columnas
      mainAxisSpacing: 10.0, // Espacio entre filas
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Para deshabilitar el desplazamiento de GridView
      childAspectRatio: 1.2, // Ajusta el aspect ratio de los cuadros
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
      'landscape': Icons.landscape,
      'apartment': Icons.apartment,
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
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Icon(
                        iconData, // Utiliza el icono correspondiente
                        color: Colors.white,
                        size: 25.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          contenido,
                          style: const TextStyle(
                            fontSize: 16.0,
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
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getServicios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DocumentSnapshot> servicios = snapshot.data!;
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.png'),
                  fit: BoxFit
                      .cover, // Ajusta la imagen para cubrir toda la pantalla
                ),
              ),
              child: SingleChildScrollView(
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
                      const SizedBox(height: 20.0),
                      _buildCuadrosDesdeFirestore(context, servicios),
                      const SizedBox(height: 20.0)
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
