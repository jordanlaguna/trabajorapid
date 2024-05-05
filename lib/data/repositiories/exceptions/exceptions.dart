/// Clase de excepcion para manejar varios errores.
class TExceptions implements Exception {
  final String message;

  const TExceptions([this.message = 'Se ha producido un error inesperado. Por favor, intenta de nuevo.']);

  /// Crea una excepcion de autenticacion a partir de un codigo de excepcion de autenticacion de Firebase.
  factory TExceptions.fromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const TExceptions('La direccion de correo electronico ya esta registrada. Por favor, utiliza un correo electronico diferente.');
      case 'invalid-email':
        return const TExceptions('La direccion de correo electronico proporcionada es invalida. Por favor, ingresa un correo electronico valido.');
      case 'weak-password':
        return const TExceptions('La contraseña es demasiado debil. Por favor, elige una contraseña mas segura.');
      case 'user-disabled':
        return const TExceptions('Esta cuenta de usuario ha sido deshabilitada. Por favor, contacta con soporte para obtener ayuda.');
      case 'user-not-found':
        return const TExceptions('Detalles de inicio de sesion no validos. Usuario no encontrado.');
      case 'wrong-password':
        return const TExceptions('Contraseña incorrecta. Por favor, verifica tu contraseña e intenta de nuevo.');
      case 'INVALID_LOGIN_CREDENTIALS':
        return const TExceptions('Credenciales de inicio de sesion no validas. Por favor, verifica tu informacion.');
      case 'too-many-requests':
        return const TExceptions('Demasiadas solicitudes. Por favor, intenta de nuevo mas tarde.');
      case 'invalid-argument':
        return const TExceptions('Argumento invalido proporcionado al metodo de autenticacion.');
      case 'invalid-password':
        return const TExceptions('Contraseña incorrecta. Por favor, intenta de nuevo.');
      case 'invalid-phone-number':
        return const TExceptions('El numero de telefono proporcionado es invalido.');
      case 'operation-not-allowed':
        return const TExceptions('El proveedor de inicio de sesion esta deshabilitado para tu proyecto de Firebase.');
      case 'session-cookie-expired':
        return const TExceptions('La cookie de sesion de Firebase ha expirado. Por favor, vuelve a iniciar sesion.');
      case 'uid-already-exists':
        return const TExceptions('El ID de usuario proporcionado ya esta siendo utilizado por otro usuario.');
      case 'sign_in_failed':
        return const TExceptions('Error de inicio de sesion. Por favor, intenta de nuevo.');
      case 'network-request-failed':
        return const TExceptions('Fallo en la solicitud de red. Por favor, verifica tu conexion a internet.');
      case 'internal-error':
        return const TExceptions('Error interno. Por favor, intenta de nuevo mas tarde.');
      case 'invalid-verification-code':
        return const TExceptions('codigo de verificacion invalido. Por favor, ingresa un codigo valido.');
      case 'invalid-verification-id':
        return const TExceptions('ID de verificacion invalido. Por favor, solicita un nuevo codigo de verificacion.');
      case 'quota-exceeded':
        return const TExceptions('Cuota excedida. Por favor, intenta de nuevo mas tarde.');
      default:
        return const TExceptions();
    }
  }
}
