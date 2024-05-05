import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/authentication/models/user_model.dart';
import 'package:trabajorapid/data/repositiories/exceptions/firebase_auth_exceptions.dart';

import '../exceptions/firebase_exceptions.dart';
import '../exceptions/format_exceptions.dart';
import '../exceptions/platform_exceptions.dart';

class UserRepository extends GetxController{
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Funcion para guardar el usuario
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code);
    // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }
}

