import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/authentication/models/user_model.dart';
import 'package:trabajorapid/data/repositiories/user/user_repository.dart';
import 'package:trabajorapid/utils/constans/loaders.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final userRepository = Get.put(UserRepository());

  // Guardar datos del usuario segun el provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials != null) {
        final fullname = userCredentials.user!.displayName ?? '';

        // Map Data
        final user = UserModel(
          uid: userCredentials.user!.uid,
          fullname: fullname,
          isActive: false,
          email: userCredentials.user!.email ?? '',
          phone: userCredentials.user!.phoneNumber ?? '',
          profilePicture: userCredentials.user!.photoURL ?? '',
        );

        // Guardar datos
        await userRepository.saveUserRecord(user);
      }
    } catch (e) {
      TLoaders.warningSnackBar(
          title: 'Datos no guardados',
          message:
              'Ocurrio un error al guardar los datos del usuario, intenta de nuevo.');
    }
  }
}
