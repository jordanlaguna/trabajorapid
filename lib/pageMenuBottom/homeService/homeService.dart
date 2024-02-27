// ignore_for_file: library_private_types_in_public_api, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:trabajorapid/mainHome/moduleMain.dart';

class HomePageService extends StatefulWidget {
  const HomePageService({Key? key}) : super(key: key);

  @override
  _HomePageServiceState createState() => _HomePageServiceState();
}

class _HomePageServiceState extends State<HomePageService> {
  final PageController _pageController =
      PageController(viewportFraction: 0.8, keepPage: true);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Configurar el desplazamiento automático
    _pageController.addListener(() {
      if (_pageController.page == _pageController.page!.toInt()) {
        // Desplazarse al siguiente elemento al llegar al final
        Future.delayed(const Duration(seconds: 4), () {
          if (currentPage == 4) {
            // Si es la última página, volver a la primera suavemente
            _pageController.animateToPage(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.bounceOut);
          } else {
            // Pasar a la siguiente página
            _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ofertas de Servicios',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 0, 0),
          ),
        ),
        centerTitle: true,
        actions: [
          // Agrega el botón de menú aquí
          PopupMenuButton<String>(
            onSelected: (value) {
              // Manejar la selección del menú
              print(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                'Más contratados',
                'Mejor calificados',
                'Más cerca',
                'Más nuevo'
              ].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Mejor calificado ⭐',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Carrusel de cuadros con información y fotos
            SizedBox(
              height: 200.0, // Ajusta la altura según tus necesidades
              child: PageView.builder(
                controller: _pageController,
                itemCount:
                    5, // Cambia el número según la cantidad de cuadros que desees
                onPageChanged: (int page) {
                  setState(() {
                    currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: buildCuadro(
                      context,
                      'Cuadro ${index + 1}',
                      'Contenido del cuadro ${index + 1}',
                    ),
                  );
                },
              ),
            ),
            // Indicador de página actual
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.6),
                  ),
                );
              }),
            ),

            // Otro contenido del código existente
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: buildCuadro(
                      context,
                      'Cuadro ${index + 1}',
                      'Contenido del cuadro ${index + 1}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildCuadro(BuildContext context, String titulo, String contenido) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ModuleMain()),
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
    home: HomePageService(),
  ));
}
