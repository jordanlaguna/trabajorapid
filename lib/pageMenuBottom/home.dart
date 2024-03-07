import 'package:flutter/material.dart';
import 'package:trabajorapid/pageMenuBottom/homeService/homeService.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color(0xffB81736),
                Color(0xff281537),
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
              buildCuadro(
                  context, 'Exteriores', 'Patios, Gardines, Arboles...'),
              const SizedBox(height: 30.0),
              buildCuadro(context, 'Interiores', 'Limpiesa, Lavanderia...'),
              const SizedBox(height: 30.0),
              buildCuadro(context, 'Transporte', 'Viajes, Carga, Express...'),
              const SizedBox(height: 30.0),
              buildCuadro(
                  context, 'Plomeria', 'Rotura, Goteras, Instalación...'),
              const SizedBox(height: 30.0),
              buildCuadro(context, 'Electricista',
                  'Cortes, Mantenimiento, Instalación...'),
              const SizedBox(height: 30.0),
              buildCuadro(
                  context, 'Mecanica', 'Llantas, Pintura, Reparación...'),
              const SizedBox(height: 30.0),
              buildCuadro(context, 'Manicura', 'Pintura, Uñas, Hidratación...'),
              const SizedBox(height: 30.0),
              buildCuadro(
                  context, 'Culinario', 'Cocinar, Eventos, Platillos...'),
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
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 1,
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
              const SizedBox(height: 10.0),
              Text(contenido),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageService()),
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

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
