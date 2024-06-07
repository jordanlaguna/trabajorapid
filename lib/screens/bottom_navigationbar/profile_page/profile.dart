import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final TextEditingController _experienciaController = TextEditingController();
  final TextEditingController _requerimientoController =
      TextEditingController();
  List<XFile>? _imageFiles;

  bool _isValidDireccion(String value) {
    // Expresión regular para verificar el formato de la dirección
    RegExp regExp = RegExp(r'^[\w\s]+\/[\w\s]+\/[\w\s]+$');
    return regExp.hasMatch(value);
  }

  bool _showDireccionError = false;
  final int _perPage = 5;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _documentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _getServicios();
  }

  @override
  void dispose() {
    // Dispose los controladores al finalizar
    _descripcionController.dispose();
    _direccionController.dispose();
    _pagoController.dispose();
    _experienciaController.dispose();
    _requerimientoController.dispose();
    super.dispose();
  }

  Future<void> _getServicios() async {
    if (!mounted) return; // Verifica si el widget todavía está montado

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('ofertasServicios').get();

      if (!mounted) {
        return; // Verifica de nuevo después de la operación asincrónica
      }

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
    } catch (e) {
      // Manejar cualquier error que ocurra durante la obtención de los servicios
      print('Error al obtener servicios: $e');
    }
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

  Future<String?> getUserPhotoUrl(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Asegúrate de convertir los datos a Map<String, dynamic> antes de acceder a ellos
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData =
            userDoc.data()! as Map<String, dynamic>; // Conversión aquí
        if (userData['photoURL'] != null) {
          return userData['photoURL']; // Acceso seguro a 'photoURL'
        }
      }

      // Revisa si hay una URL de foto disponible a través de Google Auth
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.photoURL != null) {
        return user.photoURL;
      }
    } catch (e) {
      print('Error al obtener la foto del usuario: $e');
    }
    return null; // Devuelve null si no se encuentra una URL válida
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages =
        await picker.pickMultiImage(imageQuality: 50);
    if (selectedImages.length <= 2) {
      setState(() {
        _imageFiles = selectedImages;
      });
    } else {
      // Mostrar mensaje de error si selecciona más de 2 imágenes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes seleccionar hasta 2 imágenes.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    List<String> downloadUrls = [];

    for (File image in images) {
      final String fileName = image.path.split('/').last;
      Reference ref = storage.ref().child("serviceImages").child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  void _resetForm() {
    setState(() {
      _selectedJobType = 'Seleccionar...';
      _selectedOfferType = 'Seleccionar...';
      _descripcionController.clear();
      _direccionController.clear();
      _pagoController.clear();
      _experienciaController.clear();
      _requerimientoController.clear();
      _imageFiles = null;
      _showJobForm = false;
      _showWorkHistory = false;
      _isLoading = true;
    });
    _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor(); // Estrellas completas
    double fraction = rating - fullStars; // Parte fraccionaria
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              'Perfil',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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
                  child: FutureBuilder<String?>(
                    future:
                        getUserPhotoUrl(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, photoSnapshot) {
                      if (photoSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (photoSnapshot.hasError) {
                        return const Icon(Icons.error_outline,
                            size: 30, color: Colors.red);
                      } else {
                        if (photoSnapshot.hasData &&
                            photoSnapshot.data!.isNotEmpty) {
                          return Image.network(
                            photoSnapshot.data!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          );
                        } else {
                          return const Icon(Icons.account_circle, size: 30);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text("Error al cargar los datos");
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Text(
                    userData['name'] ?? 'Nombre no disponible',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return const Text("Usuario no encontrado");
                }
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rating.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 25,
                  ),
                  if (fraction > 0)
                    const Icon(
                      Icons.star_half,
                      color: Colors.amber,
                      size: 25,
                    ),
                  for (int i = 0;
                      i < 5 - fullStars - (fraction > 0 ? 1 : 0);
                      i++)
                    const Icon(
                      Icons.star_border,
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
                  _showJobForm = false;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _buildButtonContent(Icons.history_rounded,
                  _showWorkHistory ? 'Ocultar servicios' : 'Mostrar servicios'),
            ),
            const SizedBox(height: 18),
            if (_showWorkHistory) _buildWorkHistory(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showJobForm = !_showJobForm;
                  _showWorkHistory = false;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _buildButtonContent(
                  Icons.work_outline_rounded, 'Ofrecer servicios'),
            ),
            if (_showJobForm) _buildJobForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContent(IconData icon, String text) {
    return Material(
      color: const Color.fromARGB(0, 161, 160, 160),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
          padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, color: Colors.grey[600], size: 24),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para cargar documentos
  void _loadDocuments() {
    FirebaseFirestore.instance
        .collection('servicios')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('fecha', descending: true)
        .limit(_perPage)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _documentList = querySnapshot.docs;
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _isLoading = false;
      });
    });
  }

  // Método para cargar más documentos
  void _loadMoreDocuments() {
    if (_lastDocument != null) {
      FirebaseFirestore.instance
          .collection('servicios')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('fecha', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_perPage)
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          _documentList.addAll(querySnapshot.docs);
          if (querySnapshot.docs.isNotEmpty) {
            _lastDocument = querySnapshot.docs.last;
          }
        });
      });
    }
  }

  // Método que construye el historial de trabajos
  Widget _buildWorkHistory() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else {
      return Column(
        children: [
          const Text(
            'Historial de servicios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: _documentList.map((DocumentSnapshot document) {
              var servicio = document.data() as Map<String, dynamic>;
              return _buildWorkHistoryItem(
                (servicio)['tipoServicio'] ?? '',
                (servicio)['contenido'] ?? '',
                (servicio)['fecha'].toDate(),
                (servicio)['tipoOferta'] ?? '',
                (servicio)['fotos'] ?? [],
                document.id, // Pasar el id del documento
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: _loadMoreDocuments,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 35, vertical: 15), // Aumentar padding
              textStyle:
                  const TextStyle(fontSize: 18), // Aumentar tamaño del texto
              shape: RoundedRectangleBorder(
                // Bordes redondeados más definidos
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 5, // Sombra para dar un efecto elevado
              shadowColor: Colors.blue, // Cambia el color de fondo si necesario
              backgroundColor:
                  Colors.white, // Cambia el color del texto si necesario
            ),
            child: const Text('Cargar más'),
          ),
          const SizedBox(height: 13),
        ],
      );
    }
  }

  Widget _buildWorkHistoryItem(String tipoServicio, String contenido,
      DateTime fecha, String otroDato, List<dynamic> fotos, String documentId) {
    Duration difference = DateTime.now().difference(fecha);
    String tiempoTranscurrido = '';

    if (difference.inDays > 0) {
      tiempoTranscurrido = 'Hace ${difference.inDays} día(s)';
    } else if (difference.inHours > 0) {
      tiempoTranscurrido = 'Hace ${difference.inHours} hora(s)';
    } else if (difference.inMinutes > 0) {
      tiempoTranscurrido = 'Hace ${difference.inMinutes} minuto(s)';
    } else {
      tiempoTranscurrido = 'Hace unos momentos';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 252, 250, 250)),
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 252, 250, 250),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10, top: 10, right: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10),
                  Text(
                    tipoServicio,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(248, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10, top: 10, right: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10),
                  Text(
                    tiempoTranscurrido,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(248, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                      title: const Text(
                        'Detalles del servicio',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Tipo de servicio: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: tipoServicio,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Detalle: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: contenido,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Tiempo transcurrido: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: tiempoTranscurrido,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Tipo de publicación: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: otroDato,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (fotos.isNotEmpty) ...[
                              const Text(
                                'Imágenes publicadas:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              for (int i = 0; i < fotos.length; i++)
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              maxHeight: 900,
                                              maxWidth: 400,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 300,
                                                        height: 300,
                                                        child: Image.network(
                                                          fotos[i],
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return const Center(
                                                              child: Text(
                                                                'Error al cargar la imagen',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      35,
                                                                  vertical: 15),
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          elevation: 5,
                                                          shadowColor:
                                                              Colors.blue,
                                                          backgroundColor:
                                                              Colors.white,
                                                        ),
                                                        child: const Text(
                                                          'Cerrar',
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    65,
                                                                    111,
                                                                    223),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Image.network(
                                      fotos[i],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Text(
                                            'Existe un error con la imagen solicitada',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, // Ajustar el tamaño de la columna
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  try {
                                    // Actualizar el estado del documento en Firestore
                                    await FirebaseFirestore.instance
                                        .collection('servicios')
                                        .doc(documentId)
                                        .update(
                                            {'Disponibilidad': 'Desactivo'});

                                    // Mostrar un mensaje de éxito
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'El servicio ha sido archivado con éxito.'),
                                    ));
                                  } catch (e) {
                                    // Manejar cualquier error que ocurra durante la actualización
                                    print('Error al archivar el servicio: $e');
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Error al archivar el servicio.'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 35, vertical: 15),
                                  textStyle: const TextStyle(fontSize: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.blue,
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Archivar',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 65, 111, 223),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: 20), // Espacio entre los botones
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 35, vertical: 15),
                                  textStyle: const TextStyle(fontSize: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.blue,
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Cerrar',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 65, 111, 223),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                textStyle: const TextStyle(fontSize: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 5,
                shadowColor: Colors.blue,
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Más detalles',
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
          if (_selectedOfferType == 'Oferta de servicio') ...[
            TextFormField(
              controller: _descripcionController,
              decoration:
                  const InputDecoration(labelText: 'Descripción del servicio:'),
            ),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                  labelText: 'Dirección ó zona de servicio:'),
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
            TextFormField(
              controller: _pagoController,
              decoration:
                  const InputDecoration(labelText: 'Costo del servicio:'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _pago = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            TextFormField(
              controller: _experienciaController,
              decoration: const InputDecoration(
                  labelText: 'Experiencia en el servicio que ofrece:'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Fotos de trabajos realizados:'),
              readOnly: true,
              onTap: () async {
                _pickImages();
              },
            ),
            if (_imageFiles != null && _imageFiles!.isNotEmpty)
              SizedBox(
                height: 300, // Altura fija para todas las imágenes
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Image.file(
                        File(_imageFiles![index].path),
                        width: 250, // Ancho fijo para todas las imágenes
                        height: 250, // Altura fija para todas las imágenes
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
          ] else if (_selectedOfferType == 'Oferta de empleo') ...[
            TextFormField(
              controller: _descripcionController,
              decoration:
                  const InputDecoration(labelText: 'Descripción del empleo:'),
            ),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                  labelText: 'Dirección en donde se solicita a la persona:'),
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
            TextFormField(
              controller: _pagoController,
              decoration:
                  const InputDecoration(labelText: 'Cuanto se va a pagar:'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _pago = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            TextFormField(
              controller: _requerimientoController,
              decoration: const InputDecoration(
                  labelText: '¿Se requiere experiencia?:'),
            ),
          ],
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
                  return;
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
                          String uid = user.uid;

                          List<String> downloadUrls = [];
                          if (_selectedOfferType == 'Oferta de servicio' &&
                              _imageFiles != null) {
                            List<File> files = _imageFiles!
                                .map((file) => File(file.path))
                                .toList();
                            downloadUrls = await uploadImages(files);
                          }

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
                            'uid': uid,
                            'Disponibilidad': "Activo",
                            'Administrador': "Aceptado",
                            if (_selectedOfferType == 'Oferta de servicio')
                              'experiencia': _experienciaController.text,
                            if (downloadUrls.isNotEmpty) 'fotos': downloadUrls,
                            if (_selectedOfferType == 'Oferta de empleo')
                              'requerimientos': _requerimientoController.text,
                          });

                          _resetForm();

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
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
                shadowColor: Colors.blue,
                backgroundColor: Colors.white,
              ),
              child: const Text('Publicar'),
            ),
          )
        ],
      ),
    );
  }
}
