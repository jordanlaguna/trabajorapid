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

  Widget buildCuadrosDesdeFirestore(
      BuildContext context, List<DocumentSnapshot> servicios) {
    return Column(
      children: servicios.map((servicio) {
        String titulo = servicio['titulo'];
        String contenido = servicio['contenido'];
        return Column(
          children: [
            const SizedBox(height: 30.0),
            buildCuadro(context, titulo, contenido),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ).createShader(bounds);
          },
          child: const Text(
            'Ofertas de Servicios',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Color del texto después del gradiente
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Barra de búsqueda
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar servicios...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // Carrusel
                  ],
                ),
              ),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('ofertasServicios')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DocumentSnapshot> servicios = snapshot.data!.docs;
                    return buildCarousel(context, servicios);
                  }
                },
              ),
              const SizedBox(height: 10.0),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('ofertasServicios')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DocumentSnapshot> servicios = snapshot.data!.docs;
                    return buildCuadrosDesdeFirestore(context, servicios);
                  }
                },
              ),
              const SizedBox(height: 30.0)
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildCuadro(BuildContext context, String titulo, String contenido) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 130, 19, 42)),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 90.0,
            height: 90.0,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ).createShader(bounds);
              },
              child: const Icon(
                Icons.work_history_rounded,
                size: 50.0,
                color: Colors.white,
              ),
            ),
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
              const SizedBox(height: 10.0),
              Text(contenido),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePageService(servicio: titulo),
                    ),
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
