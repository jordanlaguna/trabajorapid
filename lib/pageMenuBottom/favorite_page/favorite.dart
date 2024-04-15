import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/pageMenuBottom/favorite_page/favorite_services.dart';
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
            'Favoritos',
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
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
        // Este FutureBuilder se utiliza para obtener el documento
        // correspondiente al servicio en la colección 'Servicios'
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
              // Si la operación es exitosa, se obtiene el tipo de servicio
              // del documento obtenido
              String tipoServicio = snapshot.data!['tipoServicio'];
              // Luego, se utiliza otro FutureBuilder para obtener los servicios
              // de la colección 'ofertasServicios' que coincidan con el tipo de
              // servicio y el título del servicio
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
                          // Comparar el título del cuadro con el título más buscado
                          if (tituloCuadro == mostSearchedTitle) {
                            // Actualizar el valor de num en el cuadro
                            cuadros[i].num = maxSearches.toString();
                          }
                        }
                        return const SizedBox();
                      }
                    } else {
                      // Si no hay servicios disponibles para este tipo de servicio, devolver SizedBox
                      return const SizedBox();
                    }
                  }
                },
              );
            }
          },
        );
      } else {
        return const SizedBox(); // Si el servicio no está marcado como favorito,
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
      return Column(
        children: [
          const SizedBox(height: 30.0),
          buildCuadro(context, titulo, contenido, num),
        ],
      );
    }).toList(),
  );
}

Widget buildCuadro(
    BuildContext context, String titulo, String contenido, String num) {
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
