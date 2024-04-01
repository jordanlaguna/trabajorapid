
import 'package:flutter/material.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 130, 19, 42),
                ),
              ),
              CircleAvatar(
                radius: 90,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Jordan Laguna.',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: RatingBar.builder(
                  initialRating: 4,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemSize: 25,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    // Puedes manejar la actualización de la calificación aquí
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Ofrecer.'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                        fixedSize: Size(135, 35),
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color.fromARGB(255, 130, 19, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Aquí se añade el historial de trabajos usando el método _buildWorkHistory
              _buildWorkHistory(),
            ],
          ),
        ),
      ),
    );
  }
/**/
  
  //Este método construye el historial de trabajos
  Widget _buildWorkHistory() {
    return Column(
      
      children: <Widget>[
        Text(
          'Historial de trabajos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      
        // Usage:
        /*_buildWorkHistoryItem('Carpintería', 'Cama de madera', 'Hace 2 días'),
        _buildWorkHistoryItem('Carpintería', 'Mesa de madera', 'Hace 3 días'),
        _buildWorkHistoryItem('Carpintería', 'Silla de madera', 'Hace 4 días'),
        _buildWorkHistoryItem('Carpintería', 'Mesa de madera', 'Hace 5 días'),
        _buildWorkHistoryItem('Carpintería', 'Cama de madera', 'Hace 6 días'),
        _buildWorkHistoryItem('Carpintería', 'Cama de madera', 'Hace 7 días'),
        */
      ],
    );
  }
}
// Generated code for this Text Widget...



  /*
class _buildWorkHistoryItem extends StatelessWidget {
  final String s;
  final String t;
  final String u;

  _buildWorkHistoryItem(this.s, this.t, this.u);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black), // Define el borde general
        borderRadius:
            BorderRadius.circular(10), // Define el radio del borde general
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    s,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    t,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(248, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              u,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(248, 0, 0, 0),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Detalles del trabajo'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Aquí van los detalles del trabajo...'),
                            //  agregar más Widgets aquí mas adelante
                          ],
                        ),
                      ),

                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // Cerrar el diálogo cuando se presione el botón
                            Navigator.of(context).pop();
                          },
                          child: Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              },
              
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 10),
                fixedSize: const Size(85, 35),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                backgroundColor: const Color.fromARGB(255, 130, 19, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),

              child: const Text(
                'Mas detalles',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

}*/
