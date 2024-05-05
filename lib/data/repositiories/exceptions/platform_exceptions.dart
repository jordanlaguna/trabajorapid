class TPlatformException implements Exception {
  final String code;

  TPlatformException(this.code);

  String get message {
    switch (code) {
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Credenciales de inicio de sesion no validas. Por favor, verifica tu informacion.';
      case 'too-many-requests':
        return 'Demasiadas solicitudes. Por favor, intentalo de nuevo mas tarde.';
      case 'invalid-argument':
        return 'Argumento invalido proporcionado al metodo de autenticacion.';
      case 'invalid-password':
        return 'Contraseña incorrecta. Por favor, intentalo de nuevo.';
      case 'invalid-phone-number':
        return 'El numero de telefono proporcionado no es valido.';
      case 'operation-not-allowed':
        return 'El proveedor de inicio de sesion esta deshabilitado para tu proyecto Firebase.';
      case 'session-cookie-expired':
        return 'La cookie de sesion de Firebase ha expirado. Por favor, vuelve a iniciar sesion.';
      case 'uid-already-exists':
        return 'El ID de usuario proporcionado ya esta en uso por otro usuario.';
      case 'sign_in_failed':
        return 'Error al iniciar sesion. Por favor, intentalo de nuevo.';
      case 'network-request-failed':
        return 'La solicitud de red fallo. Por favor, verifica tu conexion a internet.';
      case 'internal-error':
        return 'Error interno. Por favor, intentalo de nuevo mas tarde.';
      case 'invalid-verification-code':
        return 'Codigo de verificacion invalido. Por favor, ingresa un codigo valido.';
      case 'invalid-verification-id':
        return 'ID de verificacion invalido. Por favor, solicita un nuevo codigo de verificacion.';
      case 'quota-exceeded':
        return 'Cuota excedida. Por favor, intentalo de nuevo mas tarde.';
      default:
        return 'Se produjo un error de plataforma inesperado. Por favor, intentalo de nuevo.';
    }
  }
}
