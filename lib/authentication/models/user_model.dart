import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabajorapid/utils/formatters/formatter.dart';

class UserModel {
  final String uid;
  String fullname;
  final bool isActive;
  final String email;
  String phone;
  String profilePicture;

  // Constructor
  UserModel({
    required this.uid,
    required this.fullname,
    required this.isActive,
    required this.email,
    required this.phone,
    required this.profilePicture,
  });

  // Para obtener el nombre completo
  //String get fullName => '$firstName $lastName';

  // Obtener el numero de telefono formateado
  String get formattedPhoneNumber => TFormatter.formatPhoneNumber(phone);

  // Obtener las partes del nombre
  static List<String> nameParts(fullName) => fullName.split(" ");

  // Generar el nombre de usuario
  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername = "$firstName$lastName";
    String usernameWithPrefix = "cwt_$camelCaseUsername";
    return usernameWithPrefix;
  }

  // constructor vacio
  static UserModel empty() => UserModel(
      uid: '',
      fullname: '',
      isActive: false,
      email: '',
      phone: '',
      profilePicture: '');

  // Convertir a json
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': fullname,
        'isActive': isActive,
        'email': email,
        'phone': phone,
        'photoURL': profilePicture,
      };

  // factory para crear un usuario desde un snapshot
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        uid: document.id,
        fullname: data['name'] ?? '',
        isActive: data['isActive'] ?? false,
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        profilePicture: data['photoURL'] ?? '',
      );
    }
    throw Exception('Ha ocurrido un error al obtener el usuario.');
  }
}
