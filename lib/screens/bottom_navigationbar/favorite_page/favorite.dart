import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/favorite_page/favorite_services.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: Favorite(),
  ));
}

class Cuadro {
  String titulo;
  String contenido;
  String num;

  Cuadro({required this.titulo, required this.contenido, required this.num});
}

class Favorite extends StatelessWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Theme.of(context).colorScheme.shadow,
                Theme.of(context).colorScheme.shadow,
              ],
            ).createShader(bounds);
          },
          child: Text(
            'Servicios Favoritos',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monserrat',
              color: Colors.blue[50],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(color: Colors.blue[50], thickness: 3.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[50]!,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    } else {
                      final User? user = userSnapshot.data;
                      if (user == null) {
                        // El usuario no ha iniciado sesión
                        return const Text('Usuario no autenticado');
                      } else {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('likes')
                              .doc(user.uid)
                              .collection('servicios')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<DocumentSnapshot> likedServicios =
                                  snapshot.data!.docs;
                              // Lista para almacenar los cuadros de información
                              List<Cuadro> cuadros = [];
                              return buildCuadrosDesdeFirestore(
                                  context, likedServicios, cuadros);
                            }
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int num = 0;

Widget buildCuadrosDesdeFirestore(
  BuildContext context,
  List<DocumentSnapshot> likedServicios,
  List<Cuadro> cuadros,
) {
  Map<String, int> countMap = {};
  Set<String> titlesSet = {}; // Conjunto para almacenar títulos únicos
  if (likedServicios.isEmpty) {
    return const Center(
      child: Text(
        'No hay ningún servicio que te guste!',
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
  return Column(
    children: likedServicios.map((likedServicio) {
      if (likedServicio['liked'] == true) {
        String servicioCode = likedServicio.id;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('servicios')
              .doc(servicioCode)
              .get(),
          builder: (context, snapshot) {
            // Si la conexión está en espera, se muestra un indicador de progreso
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            // Si hay un error, se muestra un mensaje de error
            else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String tipoServicio = snapshot.data!['tipoServicio'];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('ofertasServicios')
                    .where('titulo', isEqualTo: tipoServicio)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DocumentSnapshot> servicios = snapshot.data!.docs;
                    // Construir cuadros solo si hay servicios disponibles
                    if (servicios.isNotEmpty) {
                      // Verificar si el título ya existe en el countMap
                      if (!countMap.containsKey(tipoServicio)) {
                        // Si el título no está presente en el countMap, lo actualizamos
                        countMap.update(tipoServicio, (value) => value + 1,
                            ifAbsent: () => 1);
                      }
                      // Verificar si el título ya se ha agregado a titlesSet
                      if (!titlesSet.contains(tipoServicio)) {
                        // Si el título no está en titlesSet, agregarlo y construir el cuadro
                        titlesSet.add(tipoServicio);
                        return buildCuadros(
                          context,
                          servicios,
                          countMap[tipoServicio].toString(),
                        );
                      } else {
                        // Si el título ya está en titlesSet, incrementar el contador
                        countMap[tipoServicio] = countMap[tipoServicio]! + 1;
                        // Imprimir el mapa para verificar el conteo actualizado

                        // Validar a qué título se le agrega más 1
                        String mostSearchedTitle = '';
                        int maxSearches = 0;
                        // ignore: avoid_types_as_parameter_names
                        countMap.forEach((titulo, count) {
                          if (count > maxSearches) {
                            maxSearches = count;
                            mostSearchedTitle = titulo;
                          }
                        });
                        print('El título más buscado es $mostSearchedTitle');
                        // Iterar sobre los cuadros de información
                        for (int i = 0; i < cuadros.length; i++) {
                          // Obtener el título del cuadro
                          String tituloCuadro = cuadros[i].titulo;

                          if (tituloCuadro == mostSearchedTitle) {
                            cuadros[i].num = maxSearches.toString();
                          }
                        }
                        return const SizedBox();
                      }
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              );
            }
          },
        );
      } else {
        return const SizedBox();
        // no se muestra nada
      }
    }).toList(),
  );
}

Widget buildCuadros(
    BuildContext context, List<DocumentSnapshot> servicios, String num) {
  return Column(
    children: servicios.map((servicio) {
      String titulo = servicio['titulo'];
      String contenido = servicio['contenido'];
      String icon = servicio['icon']; // Obtener el icono del servicio
      return Column(
        children: [
          const SizedBox(height: 0.0),
          buildCuadro(context, titulo, contenido,
              icon), // Pasar el icono a la función buildCuadro
          const Divider(color: Colors.white, thickness: 3.0),
        ],
      );
    }).toList(),
  );
}

Widget buildCuadro(
    BuildContext context, String titulo, String contenido, String icon) {
  Map<String, IconData> iconos = {
    'spa': Icons.spa,
    'build': Icons.build,
    'kitchen': Icons.kitchen,
    'directions_car': Icons.directions_car,
    'format_paint': Icons.format_paint,
    'landscape': Icons.landscape,
    'apartment': Icons.apartment,
    'child_care': Icons.child_care
  };

  IconData iconData = iconos[icon] ?? Icons.error;

  return Container(
    margin: const EdgeInsets.only(bottom: 10.0),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color.fromARGB(255, 130, 19, 42)),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 45.0,
            height: 45.0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 2, 139, 252),
                shape: BoxShape.circle, // Hacer el contenedor circular
              ),
              child: Center(
                child: Icon(
                  iconData, // Usar el icono correspondiente
                  color: Colors.white,
                  size: 30.0, // Ajustar el tamaño del icono según sea necesario
                ),
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
                      builder: (context) =>
                          FavoritePageService(servicio: titulo),
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
