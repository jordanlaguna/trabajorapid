// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names, unused_local_variable
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trabajorapid/firebaseAuth/firabaseAuthImple.dart';
import 'package:quickalert/quickalert.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:trabajorapid/services/upload_image/select_image.dart';
import 'package:trabajorapid/services/upload_image/upload_image.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({Key? key}) : super(key: key);

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final FirebaseAuthImplements auth = FirebaseAuthImplements();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identificationController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final List<String> items = [
    'Masculino',
    'Femenino',
  ];
  String? selectedValue;
  File? image_upload;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  // Función para cargar la información del usuario desde Firestore
  void _loadUserInfo(String uid) async {
    DocumentSnapshot userInfo =
        await _firebaseFirestore.collection('users').doc(uid).get();

    if (userInfo.exists) {
      setState(() {
        if (_fullNameController.text.isEmpty) {
          _fullNameController.text = userInfo['name'];
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = userInfo['email'];
        }
        if (_identificationController.text.isEmpty) {
          _identificationController.text = userInfo['identification'];
        }
        if (_dateController.text.isEmpty) {
          _dateController.text = userInfo['date'];
        }
        if (_addressController.text.isEmpty) {
          _addressController.text = userInfo['address'];
        }
        if (_telephoneController.text.isEmpty) {
          _telephoneController.text = userInfo['telephone'];
        }
        if (selectedValue == null) {
          String gender = userInfo['gender'];
          selectedValue = gender;
        }
      });
    }
  }

  // Llama a esta función cuando la página se carga o cuando el usuario inicia sesión
  void _initializeUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadUserInfo(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
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
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Información Personal',
                style: TextStyle(
                  color: Color.fromARGB(255, 46, 77, 142),
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        GestureDetector(
                          onTap: () async {
                            final XFile? image = await getImage();
                            setState(() {
                              image_upload = File(image!.path);
                            });
                          },
                          child: image_upload != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.file(
                                    image_upload!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: null,
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ),
                        TextFormField(
                          controller: _identificationController,
                          decoration:  InputDecoration(
                            suffixIcon: Icon(FontAwesome.id_card, color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese su cédula',
                            hintText: '000000000',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor ingrese su cédula';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _fullNameController,
                          enabled: false,
                          decoration:  InputDecoration(
                            suffixIcon:  Icon(FontAwesome.circle_user_solid, color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese su nombre completo',
                            hintText: 'Nombre completo',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor ingrese su nombre completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          value: selectedValue,
                          hint: const Text(
                            'Seleccione',
                            style: TextStyle(fontSize: 15),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue;
                            });
                          },
                          items: items.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            suffixIcon: Icon(FontAwesome.venus_mars_solid, color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Género',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 23,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor seleccione el género';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: InputDecoration(
                            suffixIcon:  Icon(FontAwesome.envelope_solid, color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese su correo',
                            hintText: 'ejemplousuaro@gmail.com',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor ingrese un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            suffixIcon:  Icon(FontAwesome.calendar_xmark_solid, color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese su fecha de nacimiento',
                            hintText: 'dd/mm/aaaa',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor ingrese su fecha de nacimiento';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            suffixIcon: Icon(FontAwesome.location_dot_solid, color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese su dirección completa',
                            hintText: 'Provincia/Cantón/Distrito/',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor ingrese su dirección completa';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _telephoneController,
                          decoration: InputDecoration(
                            suffixIcon: Icon(FontAwesome.phone_solid, color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese su número de teléfono',
                            hintText: '00000000',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor ingrese su número de teléfono';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (image_upload == null) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: 'Error: No se ha seleccionado ninguna imagen.',
              autoCloseDuration: const Duration(seconds: 2),
              showConfirmBtn: false,
            );
            return;
          }

          final uploaded = await uploadImage(image_upload!);

          if (_formKey.currentState!.validate()) {
            _registerUser(context);
          } else {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              updateUserDataFromGoogle(user);
            }
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 65, 111, 223),
                Color.fromARGB(255, 110, 174, 231),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  // create method to register user
  void _registerUser(BuildContext context) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final String fullName = _fullNameController.text;
    final String email = _emailController.text;
    final String identification = _identificationController.text;
    final String date = _dateController.text;
    final String address = _addressController.text;
    final String telephone = _telephoneController.text;
    final String gender = selectedValue!;

    try {
      DocumentSnapshot userDoc =
          await _firebaseFirestore.collection('users').doc(currentUserId).get();

      // Check if user document exists
      if (!userDoc.exists) {
        // User is new, register the data
        if (identification.isNotEmpty &&
            date.isNotEmpty &&
            address.isNotEmpty &&
            telephone.isNotEmpty &&
            gender.isNotEmpty) {
          try {
            DocumentSnapshot userDoc = await _firebaseFirestore
                .collection('users')
                .doc(currentUserId)
                .get();
            if (userDoc.exists) {
              Map<String, dynamic> userData =
                  userDoc.data() as Map<String, dynamic>;
              // We check if the data is already registered
              if (userData['identification'] == identification &&
                  userData['date'] == date &&
                  userData['address'] == address &&
                  userData['telephone'] == telephone &&
                  userData['gender'] == gender) {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.warning,
                  text: '¡Todos los datos ya están registrados!',
                  autoCloseDuration: const Duration(seconds: 2),
                  showConfirmBtn: false,
                );
                return;
              }
            }
            Map<String, dynamic> newData = {
              if (fullName.isNotEmpty) 'name': fullName,
              if (email.isNotEmpty) 'email': email,
              'identification': identification,
              'gender': gender,
              'date': date,
              'address': address,
              'telephone': telephone
            };
            await _firebaseFirestore
                .collection('users')
                .doc(currentUserId)
                .set(newData);
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: '¡Registro exitoso!',
              autoCloseDuration: const Duration(seconds: 2),
              showConfirmBtn: false,
            );
          } catch (e) {
            print(e);
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: 'Hubo un error al procesar la solicitud.',
              autoCloseDuration: const Duration(seconds: 2),
              showConfirmBtn: false,
            );
          }
        }
      } else {
        // User already exists, check if data is already registered
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['identification'] == identification &&
            userData['date'] == date &&
            userData['address'] == address &&
            userData['telephone'] == telephone &&
            userData['gender'] == gender) {
          // All data is already registered
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            text: '¡Todos los datos ya están registrados!',
            autoCloseDuration: const Duration(seconds: 2),
            showConfirmBtn: false,
          );
        } else {
          // Update user data
          Map<String, dynamic> newData = {
            if (fullName.isNotEmpty) 'name': fullName,
            if (email.isNotEmpty) 'email': email,
            'identification': identification,
            'gender': gender,
            'date': date,
            'address': address,
            'telephone': telephone
          };
          await _firebaseFirestore
              .collection('users')
              .doc(currentUserId)
              .update(newData);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: '¡Registro exitoso!',
            autoCloseDuration: const Duration(seconds: 2),
            showConfirmBtn: false,
          );
        }
      }
    } catch (e) {
      print(e);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Hubo un error al procesar la solicitud.',
        autoCloseDuration: const Duration(seconds: 2),
        showConfirmBtn: false,
      );
    }
  }

  //Selected image from gallery or camera

  //Method for upload photo of profile in firebase storage and get url of photo
  Future<void> uploadProfilePhoto(File? imageFile) async {
    try {
      if (imageFile == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Error: No se ha seleccionado ninguna imagen.',
          autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: false,
        );
        return;
      }

      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_photos/$fileName');
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final String photoUrl = await taskSnapshot.ref.getDownloadURL();

      await _firebaseFirestore
          .collection('users')
          .doc(currentUserId)
          .update({'photoUrl': photoUrl});

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Foto de perfil cargada con éxito!',
        autoCloseDuration: const Duration(seconds: 2),
        showConfirmBtn: false,
      );
    } catch (e) {
      print(e);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Hubo un error al cargar la foto de perfil.',
        autoCloseDuration: const Duration(seconds: 2),
        showConfirmBtn: false,
      );
    }
  }

  void updateUserDataFromGoogle(User user) async {
    String? email = user.email;
    String? name = user.displayName;
    String uid = user.uid;

    if (email != null && name != null) {
      DocumentSnapshot userDoc =
          await _firebaseFirestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        await _firebaseFirestore.collection('users').doc(uid).set({
          'email': email,
          'name': name,
          'photoUrl': user.photoURL,
        });
      }
    }
  }
}
