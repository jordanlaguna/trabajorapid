import 'package:flutter/material.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showWorkHistory = false;
  bool _showJobForm = false;
  double rating = 4.5;
  String _selectedJobType = 'Seleccionar...'; 

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor(); // Estrellas completas
    double fraction = rating - fullStars; // Parte fraccionaria
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Text(
                      rating.toString(), // Mostrar el valor de la calificación
                      style: TextStyle(fontSize: 20),
                    ),
                    Icon(
                      Icons.star, // Ícono de estrella completa
                      color: Colors.amber,
                      size: 25,
                    ),
                    if (fraction > 0) // Mostrar estrella parcial si hay fracción
                      Icon(
                        Icons.star_half, // Ícono de estrella parcial
                        color: Colors.amber,
                        size: 25,
                      ),
                    for (int i = 0;
                        i < 5 - fullStars - (fraction > 0 ? 1 : 0);
                        i++) // Mostrar estrellas vacías restantes
                      Icon(
                        Icons.star_border, // Ícono de estrella vacía
                        color: Colors.amber,
                        size: 25,
                      ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showWorkHistory = !_showWorkHistory;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Material(
                  color: Color.fromARGB(0, 161, 160, 160),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Color de fondo gris como ejemplo
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),

                    alignment: AlignmentDirectional(0, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: Colors.grey[600], // Color de icono gris como ejemplo
                            size: 24,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                            child: Text(
                              _showWorkHistory ? 'Ocultar trabajos' : 'Mostrar trabajos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800], // Color de texto gris como ejemplo
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[600], // Color de icono gris como ejemplo
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),
              if (_showWorkHistory) _buildWorkHistory(), // Mostrar historial de trabajos si _showWorkHistory es true
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showJobForm = !_showJobForm;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Color de fondo gris como ejemplo
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: AlignmentDirectional(0, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.work_outline_rounded,
                            color: Colors.grey[600], // Color de icono gris como ejemplo
                            size: 24,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                            child: Text(
                              'Ofrecer trabajos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800], // Color de texto gris como ejemplo
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[600], // Color de icono gris como ejemplo
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_showJobForm) _buildJobForm(), // Mostrar formulario de trabajo si _showJobForm es true
            ],
          ),
        ),
      ),
    );
  }

  // Este método construye el historial de trabajos
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
        _buildWorkHistoryItem('Carpintería', 'Cama de madera', 'Hace 2 días'),
        _buildWorkHistoryItem('Carpintería', 'Mesa de madera', 'Hace 3 días'),
        _buildWorkHistoryItem('Carpintería', 'Silla de madera', 'Hace 4 días'),
        _buildWorkHistoryItem('Carpintería', 'Mesa de madera', 'Hace 5 días'),
        _buildWorkHistoryItem('Carpintería', 'Cama de madera', 'Hace 6 días'),
        _buildWorkHistoryItem('Carpintería', 'Cama de madera', 'Hace 7 días'),
      ],
    );
  }

  Widget _buildWorkHistoryItem(String s, String t, String u) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black), // Define el borde general
        borderRadius: BorderRadius.circular(10), // Define el radio del borde general
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

 
  // Método para construir el formulario de trabajo
  Widget _buildJobForm() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publicar Trabajo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedJobType,
            onChanged: (String? newValue) {
              setState(() {
                _selectedJobType = newValue!;
              });
            },
            items: <String>['Seleccionar...','Manicura.', 'Transporte.', 'Culinaria.', 'Exteriores.','Interiores.', 'Otro.']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Tipo de trabajo.',
            ),
          ),
           TextFormField(
            decoration: InputDecoration(labelText: 'Descripción del trabajo.'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Ubicación.'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Dirección exacta.'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Pago.'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Aquí puedes manejar la lógica para enviar el formulario
            },
            child: Text('Publicar'),
          ),
        ],
      ),
    );
  }
}
