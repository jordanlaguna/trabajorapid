import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ofertas de trabajo',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 0, 0),
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
              buildCuadro('Cuadro 1', 'Contenido del cuadro 1'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 2', 'Contenido del cuadro 2'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 3', 'Contenido del cuadro 3'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 4', 'Contenido del cuadro 4'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 5', 'Contenido del cuadro 5'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 6', 'Contenido del cuadro 6'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 7', 'Contenido del cuadro 7'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 8', 'Contenido del cuadro 8'),
              const SizedBox(height: 30.0),
              buildCuadro('Cuadro 9', 'Contenido del cuadro 9'),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildCuadro(String titulo, String contenido) {
  return Container(
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
              const SizedBox(height: 10.0),
              Text(contenido),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Acción del botón
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
