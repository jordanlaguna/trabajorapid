// ignore_for_file: unnecessary_import, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> _servicios = [];
  bool _showWorkHistory = false;
  bool _showJobForm = false;
  double rating = 4.5;
  String _selectedJobType = 'Seleccionar...';
  String _selectedOfferType = 'Seleccionar...';
  double _pago = 0.0;
  DateTime currentDate = DateTime.now();
  Position? position;
  // Declara los controladores para los campos de texto
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _pagoController = TextEditingController();

  bool _isValidDireccion(String value) {
    // Expresión regular para verificar el formato de la dirección
    RegExp regExp = RegExp(r'^[\w\s]+\/[\w\s]+\/[\w\s]+$');
    return regExp.hasMatch(value);
  }

  bool _showDireccionError = false;
  @override
  void initState() {
    super.initState();
    _getServicios();
    //_getCurrentPosition(); // Llama a la función para obtener los servicios al inicializar el estado
  }

  @override
  void dispose() {
    // Dispose los controladores al finalizar
    _descripcionController.dispose();
    _direccionController.dispose();
    _pagoController.dispose();
    _getServicios(); // Llama a la función para obtener los servicios al inicializar el estado

    super.dispose();
  }

  // Función para obtener los servicios de Firestore
  Future<void> _getServicios() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ofertasServicios').get();

    setState(() {
      // Filtra los documentos y convierte explícitamente a String
      _servicios = querySnapshot.docs
          .where((doc) => doc.exists && doc['titulo'] != null)
          .map((doc) => doc['titulo'] as String)
          .toList();

      // Eliminar duplicados y asegurar que 'Seleccionar...' esté al principio
      _servicios = _servicios.toSet().toList();
      _servicios.insert(0, 'Seleccionar...');
    });
  }

  Future<Position> determinePosicion() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position newPosition = await determinePosicion();
    setState(() {
      position = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor(); // Estrellas completas
    double fraction = rating - fullStars; // Parte fraccionaria
    return SingleChildScrollView(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              const Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 130, 19, 42),
                ),
              ),
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: FirebaseAuth.instance.currentUser!.photoURL != null
                        ? Image.network(
                            FirebaseAuth.instance.currentUser!.photoURL!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.account_circle,
                            size:
                                150), // Icono de usuario predeterminado si no hay URL de foto
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Nombre',
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
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Icon(
                      Icons.star, // Ícono de estrella completa
                      color: Colors.amber,
                      size: 25,
                    ),
                    if (fraction >
                        0) // Mostrar estrella parcial si hay fracción
                      const Icon(
                        Icons.star_half, // Ícono de estrella parcial
                        color: Colors.amber,
                        size: 25,
                      ),
                    for (int i = 0;
                        i < 5 - fullStars - (fraction > 0 ? 1 : 0);
                        i++) // Mostrar estrellas vacías restantes
                      const Icon(
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
                  color: const Color.fromARGB(0, 161, 160, 160),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          Colors.grey[200], // Color de fondo gris como ejemplo
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: const AlignmentDirectional(0, 0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: Colors
                                .grey[600], // Color de icono gris como ejemplo
                            size: 24,
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12, 0, 0, 0),
                            child: Text(
                              _showWorkHistory
                                  ? 'Ocultar servicios'
                                  : 'Mostrar servicios',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[
                                    800], // Color de texto gris como ejemplo
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[
                                    600], // Color de icono gris como ejemplo
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
              const SizedBox(height: 18),
              if (_showWorkHistory)
                _buildWorkHistory(), // Mostrar historial de trabajos si _showWorkHistory es true
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
                      color:
                          Colors.grey[200], // Color de fondo gris como ejemplo
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: const AlignmentDirectional(0, 0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.work_outline_rounded,
                            color: Colors
                                .grey[600], // Color de icono gris como ejemplo
                            size: 24,
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12, 0, 0, 0),
                            child: Text(
                              'Ofrecer servicios',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[
                                    800], // Color de texto gris como ejemplo
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[
                                    600], // Color de icono gris como ejemplo
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
              if (_showJobForm)
                _buildJobForm(), // Mostrar formulario de trabajo si _showJobForm es true
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
        const Text(
          'Historial de servicios',
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
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    t,
                    style: const TextStyle(
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
              style: const TextStyle(
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
                      title: const Text('Detalles del servicio'),
                      content: const SingleChildScrollView(
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
                          child: const Text('Cerrar'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Publicar Oferta',
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
            items: _servicios.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Tipo de servicio:',
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedOfferType,
            onChanged: (String? newValue) {
              setState(() {
                _selectedOfferType = newValue!;
              });
            },
            items: ['Seleccionar...', 'Oferta de servicio', 'Oferta de empleo']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Tipo de oferta:',
            ),
          ),
          TextFormField(
            controller:
                _descripcionController, // Controlador para el campo de descripción
            decoration:
                const InputDecoration(labelText: 'Descripción del servicio:'),
          ),
          TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(labelText: 'Dirección:'),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              setState(() {
                _showDireccionError = !_isValidDireccion(value);
              });
            },
            onEditingComplete: () {
              setState(() {
                _showDireccionError = false;
              });
            },
            validator: (value) {
              if (_showDireccionError && !_isValidDireccion(value!)) {
                return 'La dirección no tiene un formato válido.';
              }
              return null;
            },
          ),

          // Campo de pago
          TextFormField(
            controller: _pagoController,
            decoration: const InputDecoration(labelText: 'Pago:'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _pago = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                // Verificar si hay un usuario autenticado
                User? user = FirebaseAuth.instance.currentUser;
                getCurrentLocation();

                if (!_isValidDireccion(_direccionController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'La dirección no tiene un formato válido. Por ejemplo: '
                        'Provincia/Canton/Ciudad'),
                    backgroundColor: Colors.red,
                  ));
                  return; // Detener el proceso de publicación si la dirección no es válida
                }

                if (user != null) {
                  String uid = user.uid;

                  // Generar un ID aleatorio para el servicio
                  String servicioId = FirebaseFirestore.instance
                      .collection('servicios')
                      .doc()
                      .id;
                  // Verificar si el ID ya existe en la colección de servicios
                  bool idExiste = await FirebaseFirestore.instance
                      .collection('servicios')
                      .doc(servicioId)
                      .get()
                      .then((doc) => doc.exists);

                  if (!idExiste) {
                    // Buscar el usuario en la colección 'users'
                    DocumentSnapshot userSnapshot = await FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(uid)
                        .get();

                    if (userSnapshot.exists) {
                      // Convertir el resultado de data() a un Map<String, dynamic>
                      Map<String, dynamic>? userData =
                          userSnapshot.data() as Map<String, dynamic>?;

                      if (userData != null && userData.containsKey('name')) {
                        // Extraer el nombre del usuario si está presente en los datos
                        String userName = userData['name'];

                        // Verificar si el tipo de servicio seleccionado está en la colección ofertasServicio
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('ofertasServicios')
                            .where('titulo', isEqualTo: _selectedJobType)
                            .limit(1)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          // Obtener la descripción, dirección y pago del formulario
                          String descripcion = _descripcionController.text;
                          String direccion = _direccionController.text;
                          String uid = user.uid; // Obtener el UID del usuario

                          // Guardar la información en la colección servicios
                          await FirebaseFirestore.instance
                              .collection('servicios')
                              .doc(servicioId)
                              .set({
                            'contenido': descripcion,
                            'titulo': userName,
                            'tipoServicio': _selectedJobType,
                            'tipoOferta': _selectedOfferType,
                            'direccion': direccion,
                            'pago': _pago,
                            'latitude': position?.latitude,
                            'longitude': position?.longitude,
                            'fecha': currentDate,
                            'id': servicioId,
                            'uid': uid
                          });

                          // Limpiar los campos del formulario después de guardar la información
                          _descripcionController.clear();
                          _direccionController.clear();
                          _pagoController.clear();

                          // Mostrar un mensaje de éxito
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'El servicio ha sido publicado con éxito.'),
                          ));
                        } else {
                          // Si el tipo de servicio no está en la colección ofertasServicio
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'El tipo de servicio seleccionado no está disponible.'),
                          ));
                        }
                      } else {
                        // Si no se encuentra el nombre del usuario en los datos
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content:
                              Text('El nombre del usuario no está disponible.'),
                        ));
                      }
                    } else {
                      // Si no se encuentra el usuario en la colección 'users'
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('El usuario no está registrado.'),
                      ));
                    }
                  } else {
                    // Si el ID ya existe en la colección de servicios
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Error: El servicio no se puede publicar debido a un conflicto de ID.'),
                    ));
                  }
                } else {
                  // Si no hay usuario autenticado
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Debes iniciar sesión para publicar un servicio.'),
                  ));
                }
              },
              child: const Text('Publicar'),
            ),
          )
        ],
      ),
    );
  }
}
