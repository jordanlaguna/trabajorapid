import 'package:flutter/material.dart';

class PageLegal extends StatelessWidget {
  const PageLegal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Información Legal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: const <Widget>[
            ListTile(
              title: Text(
                '¿Quiénes Somos?',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'Rapidjobs es una plataforma de empleo que conecta a empleadores con trabajadores y viceversa. Nuestro objetivo es facilitar la búsqueda de empleo y la contratación de personal. Para toda aquella persona que busque empleo o quiera contratar personal, Rapidjobs es la solución.',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
            ),
            Divider(), // Separador entre elementos de la lista
            ListTile(
              title: Text(
                '¿De Dónde Somos?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'Rapidjobs es una aplicación de origen costarricense, esta aplicación fue creada por un grupo de cuatro estudiantes de ingeniería en sistemas de la Universidad Nacional de Costa Rica, sede regional Brunca, campus Coto. La idea de la aplicación surgió en el año 2023, con el objetivo de facilitar la búsqueda de empleo y la contratación de personal en la región.\nLa zona de cobertura de Rapidjobs es la región Coto, en la provincia de Puntarenas, Costa Rica. Sin embargo, la aplicación está en constante crecimiento y se espera que en un futuro cercano se expanda a otras regiones del país.',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Creadores de la Aplicación',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'La aplicación RapidJobs fue creada por los desarrolladores Antony Valverde Rojas, Jordan Laguna Rodríguez, Jocsan Ramírez Chavez y Julio Cabrera Ortega, estudiantes de la carrera ingeniería en sistema.\nCompartiendo la misma idea de facilitar la búsqueda de empleo y la contratación de personal en la región Coto, decidieron unir esfuerzos y conocimientos para crear esta aplicación.\n',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Copyright',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                '©2024 RapidJobs. Todos los derechos reservados.\nRapidJobs es una marca registrada de RapidJobs.\nEl uso de esta aplicación está sujeto a los términos y condiciones de uso de RapidJobs.',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
