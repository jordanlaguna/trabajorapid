// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getUserPhotoURL(String userID) async {
  if (userID.isEmpty) {
    return null;
  }

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si el usuario ha iniciado sesión con Google
      if (user.providerData
          .any((userInfo) => userInfo.providerId == 'google.com')) {
        return user.photoURL;
      }
      // Si el usuario ha iniciado sesión con Facebook
      else if (user.providerData
          .any((userInfo) => userInfo.providerId == 'facebook.com')) {
        return 'https://graph.facebook.com/${user.uid}/picture?height=500';
      }
    }

    // Si no es un inicio de sesión de Google o Facebook, obtenemos la foto de Firestore
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final DocumentSnapshot document = await users.doc(userID).get();

    if (document.exists) {
      Map<String, dynamic>? userData = document.data() as Map<String, dynamic>?;

      if (userData != null && userData['photoURL'] != null) {
        return userData['photoURL'];
      } else {
        return null;
      }
    } else {
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}
