// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names, unused_local_variable
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final List<String> items = ['Masculino', 'Femenino'];
  String? selectedValue;

  File? image_upload;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _loadUserInfo(String uid) async {
    DocumentSnapshot userInfo =
        await _firebaseFirestore.collection('users').doc(uid).get();

    if (userInfo.exists) {
      final data = userInfo.data() as Map<String, dynamic>;
      setState(() {
        _fullNameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _identificationController.text = data['identification'] ?? '';
        _dateController.text = data['date'] ?? '';
        _addressController.text = data['address'] ?? '';
        _telephoneController.text = data['phone'] ?? '';
        selectedValue = data['gender'] != null && items.contains(data['gender'])
            ? data['gender']
            : null;
      });
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _fullNameController.text = user.displayName ?? '';
          _emailController.text = user.email ?? '';
        });
        updateUserDataFromGoogle(user);
      }
    }
  }

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: FloatingActionButton(
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
                print('Botón de agregar presionado');

                if (_formKey.currentState!.validate()) {
                  print('Formulario válido, registrando usuario...');
                  _registerUser(context);
                } else {
                  print('Formulario no válido');
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade200, Colors.grey.shade200],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                            final image = await getImage();
                            if (image != null) {
                              setState(() {
                                image_upload = File(image.path);
                              });
                            }
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
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Color.fromARGB(255, 65, 111, 223),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _identificationController,
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              FontAwesome.id_card,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                            labelText: 'Ingrese su cédula',
                            hintText: '000000000',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.7),
                                width: 2.0,
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
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              FontAwesome.circle_user_solid,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                            labelText: 'Ingrese su nombre completo',
                            hintText: 'Nombre completo',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.7),
                                width: 2.0,
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
                          value: selectedValue != null &&
                                  items.contains(selectedValue)
                              ? selectedValue
                              : null,
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
                            suffixIcon: const Icon(
                              FontAwesome.venus_mars_solid,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                            labelText: 'Género',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 23,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.7),
                                width: 2.0,
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
                            suffixIcon: const Icon(
                              FontAwesome.envelope_solid,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                            labelText: 'Ingrese su correo',
                            hintText: 'ejemplousuario@gmail.com',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.7),
                                width: 2.0,
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
                            suffixIcon: const Icon(
                              FontAwesome.calendar_xmark_solid,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                            labelText: 'Ingrese su fecha de nacimiento',
                            hintText: 'dd/mm/aaaa',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.7),
                                width: 2.0,
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
                            suffixIcon: const Icon(
                              FontAwesome.location_dot_solid,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                            labelText: 'Ingrese su dirección completa',
                            hintText: 'Provincia/Cantón/Distrito/',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.7),
                                width: 2.0,
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
                            suffixIcon: const Icon(
                              FontAwesome.phone_solid,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                            labelText: 'Ingrese su número de teléfono',
                            hintText: '00000000',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 17,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.7),
                                width: 2.0,
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
    );
  }

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
      print('Registrando usuario...');
      DocumentSnapshot userDoc =
          await _firebaseFirestore.collection('users').doc(currentUserId).get();

      if (!userDoc.exists) {
        if (identification.isNotEmpty &&
            date.isNotEmpty &&
            address.isNotEmpty &&
            telephone.isNotEmpty &&
            gender.isNotEmpty) {
          try {
            Map<String, dynamic> newData = {
              if (fullName.isNotEmpty) 'name': fullName,
              if (email.isNotEmpty) 'email': email,
              'identification': identification,
              'gender': gender,
              'date': date,
              'address': address,
              'phone': telephone,
            };
            print('Datos a registrar: $newData');
            await _firebaseFirestore
                .collection('users')
                .doc(currentUserId)
                .set(newData);
            print('Datos registrados exitosamente');
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: '¡Registro exitoso!',
              autoCloseDuration: const Duration(seconds: 2),
              showConfirmBtn: false,
            );
          } catch (e) {
            print('Error al registrar datos: $e');
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
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['identification'] == identification &&
            userData['date'] == date &&
            userData['address'] == address &&
            userData['phone'] == telephone &&
            userData['gender'] == gender) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            text: '¡Todos los datos ya están registrados!',
            autoCloseDuration: const Duration(seconds: 2),
            showConfirmBtn: false,
          );
        } else {
          Map<String, dynamic> newData = {
            if (fullName.isNotEmpty) 'name': fullName,
            if (email.isNotEmpty) 'email': email,
            'identification': identification,
            'gender': gender,
            'date': date,
            'address': address,
            'phone': telephone,
          };
          print('Datos a actualizar: $newData');
          await _firebaseFirestore
              .collection('users')
              .doc(currentUserId)
              .update(newData);
          print('Datos actualizados exitosamente');
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
      print('Error en el proceso de registro: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Hubo un error al procesar la solicitud.',
        autoCloseDuration: const Duration(seconds: 2),
        showConfirmBtn: false,
      );
    }
  }

  void updateUserDataFromGoogle(User user) async {
    final String identification = _identificationController.text;
    final String date = _dateController.text;
    final String address = _addressController.text;
    final String telephone = _telephoneController.text;
    final String gender = selectedValue ?? '';
    String? email = user.email;
    String? name = user.displayName;
    String uid = user.uid;

    if (email != null && name != null) {
      try {
        DocumentSnapshot userDoc =
            await _firebaseFirestore.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          Map<String, dynamic> userData = {
            'name': name,
            'email': email,
            'gender': gender,
            'address': address,
            'phone': telephone,
            'photoURL': user.photoURL,
            'date': date,
            'uid': uid,
          };
          await _firebaseFirestore.collection('users').doc(uid).set(userData);

          // Actualizar los controladores con los datos del usuario
          setState(() {
            _fullNameController.text = name;
            _emailController.text = email;
            _telephoneController.text = telephone;
          });
        } else {
          // Actualizar los controladores con los datos del usuario si ya existe en Firestore
          setState(() {
            _fullNameController.text = userDoc['name'];
            _emailController.text = userDoc['email'];
            _telephoneController.text = userDoc['phone'];
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
