import 'package:flutter/material.dart';

class PagePolicy extends StatelessWidget {
  const PagePolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Politicas De Privacidad',
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
                'A. Recopilación De Información',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                '- Información que usted nos facilita\n'
                '- Información que recopilamos automáticamente\n'
                '- Información de otras fuentes',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(), // Separador entre elementos de la lista
            ListTile(
              title: Text(
                'B. Uso De La Información',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'C. Uso De Datos Personales',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'D. Medidas De Seguridad',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'E. Cambios En La Política De Privacidad',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'F. Cookies',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'G. Conservación De Datos',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(),
            ListTile(
              subtitle: Text(
                'En rapidjobs, estamos comprometidos con la protección de su privacidad. Esta Política de Privacidad describe cómo recopilamos, usamos y compartimos información sobre usted. Esta política se aplica a la información que recopilamos cuando utiliza nuestros sitios web, aplicaciones móviles y otros servicios en línea que enlazan o hacen referencia a esta política (en conjunto, nuestros "Servicios").\n',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'A. Recopilación De Información',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'La información que recopilamos sobre usted varía según la forma en que utiliza nuestros Servicios. A continuación, explicamos cómo recopilamos información sobre usted y cómo se utiliza esa información.\nLa información que usted nos facilita: Recopilamos información que usted nos facilita directamente. Por ejemplo, recopilamos información cuando crea una cuenta, participa en eventos, solicita servicios, se comunica con nosotros. La información que recopilamos puede incluir su nombre, dirección de correo electrónico, número de teléfono, foto de perfil, datos de pago y otra información que elija proporcionar.\nInformación que recopilamos automáticamente: Recopilamos información sobre usted cuando utiliza nuestros Servicios. Por ejemplo, recopilamos información sobre cómo interactúa con nuestros Servicios, como las servicios que visita, los anuncios con los que interactúa y otros comportamientos en línea. Recopilamos información sobre su dispositivo y conexión, como su ubicación, sistema operativo, datos de registro.\n',
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
                'B. Uso De La Información',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'Utilizamos la información que recopilamos para proporcionar, mantener y mejorar nuestros Servicios, para desarrollar nuevos servicios y para proteger rapidjobs y nuestros usuarios. Por ejemplo, utilizamos la información para:\n - Crear y mantener su cuenta.\n - Procesar transacciones.\n - Proporcionar servicios y asistencia al cliente.\n - Desarrollar nuevos servicios.\n - Proteger rapidjobs y nuestros usuarios.\n - Comunicarnos con usted.\n - Personalizar nuestros servicios.\n',
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
                'C. Uso De Datos Personales',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'No compartimos información personal con empresas, organizaciones o individuos externos a rapidjobs, excepto en las siguientes circunstancias:\n - Con su consentimiento.\n - Con administradores de dominios.\n - Con proveedores de servicios.\n - Por motivos legales.\n - En caso de una fusión o adquisición.\n',
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
                'D. Medidas De Seguridad',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'Tomamos medidas razonables para proteger la información sobre usted contra pérdida, robo, uso no autorizado, divulgación, alteración y destrucción. Por ejemplo, encriptamos la información que recopilamos.\n',
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
                'E. Cambios En La Política De Privacidad',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'Nos reservamos el derecho de modificar esta Política de Privacidad en cualquier momento. Si realizamos cambios en la Política de Privacidad, le notificaremos y actualizaremos la "Fecha de entrada en vigor" en la parte superior de la Política de Privacidad. Si realizamos cambios significativos en la Política de Privacidad, le informaremos de los cambios a través de nuestros Servicios o por otros medios, como el correo electrónico.\n',
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
                'F. Cookies',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'Utilizamos cookies y tecnologías similares para proporcionar, proteger y mejorar nuestros Servicios. Puede configurar su navegador para que rechace todas las cookies o para que le avise cuando se envía una cookie. Si deshabilita las cookies, es posible que algunas funciones de nuestros Servicios no funcionen correctamente.\n',
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
                'G. Conservación De Datos',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'Conservamos la información que recopilamos durante el tiempo necesario para proporcionar nuestros servicios y cumplir con nuestras obligaciones legales, resolver disputas y hacer cumplir nuestros acuerdos. Conservamos la información que recopilamos durante el tiempo necesario para proporcionar nuestros servicios y cumplir con nuestras obligaciones legales, resolver disputas y hacer cumplir nuestros acuerdos.\n',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
