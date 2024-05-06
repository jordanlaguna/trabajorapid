import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PageQuest extends StatelessWidget {
  const PageQuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Preguntas Frecuentes',
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
                '¿Qué es RapidJobs?',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'Rapidjobs es una plataforma de empleo que conecta a empleadores con trabajadores y viceversa. Nuestro objetivo es facilitar la búsqueda de empleo y la contratación de personal, para toda aquella persona que busque empleo o quiera contratar personal.',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
            ),
            Divider(), // Separador entre elementos de la lista
            ListTile(
              title: Text(
                '¿Para quién es RapidJobs?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'RapidJobs es para cualquier persona que busque empleo o quiera contratar personal. Nuestra plataforma es fácil de usar y está diseñada para que cualquier persona pueda utilizarla sin importar su nivel de conocimiento en tecnología.',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                '¿Dónde se encuentra disponible RapidJobs?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'RapidJobs está disponible en la zona sur de Costa Rica. Puedes acceder a nuestra plataforma desde cualquier lugar y en cualquier momento.',
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
                '¿Cómo ganarán dinero con RapidJobs?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'RapidJobs es una plataforma gratuita para los trabajadores. Los empleadores no pagarán una tarifa por publicar sus ofertas de empleo. Además, ofrecemos servicios adicionales como la verificación de antecedentes y la verificación de referencias, que no tienen un costo adicional.',
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
                '¿Ingresos de RapidJobs?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'RapidJobs no cobra una tarifa por publicar ofertas de empleo. Sin embargo, se cobrará un porcentaje mínimo por trabajos realizados. Además, RapidJobs se reserva el derecho de cobrar una tarifa por el uso de la plataforma al publicar una oferta de empleo en el futuro.',
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
                '¿Edad de RapidJobs?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'RapidJobs fue fundada en 2024 por un grupo de emprendedores que querían facilitar la búsqueda de empleo y la contratación de personal. Nuestra plataforma ha sido diseñada para ser fácil de usar y accesible para cualquier persona que busque empleo o quiera contratar personal.',
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
                '¿Fundadores de RapidJobs?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                'RapidJobs fue fundada por un grupo de emprendedores que querían facilitar la búsqueda de empleo y la contratación de personal. Nuestro equipo está formado por Antony Valverde Rojas, Jordan Laguna Rodríguez, Jocsan Ramírez Chavez y Julio Cabrera Ortega profesionales con experiencia en el sector de la tecnología y el empleo, que están comprometidos con el éxito de nuestra plataforma.',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
