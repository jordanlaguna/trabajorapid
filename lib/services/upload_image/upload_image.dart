// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

Future<bool> uploadImage(File image) async {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  try {
    final String fileName = image.path.split('/').last;

    Reference ref = storage.ref().child("profileUsers").child(fileName);
    final UploadTask uploadTask = ref.putFile(image);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
    final String url = await snapshot.ref.getDownloadURL();
    await _firebaseFirestore.collection("users").doc(currentUserId).update({
      "photoURL": url,
    });
    return true;
  } catch (e) {
    print(e);
  }
  return false;
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
