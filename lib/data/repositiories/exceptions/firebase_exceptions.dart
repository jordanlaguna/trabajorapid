class TFirebaseException implements Exception {
  final String code;

  TFirebaseException(this.code);

  String get message {
    switch (code) {
      case 'unknown':
        return 'Se produjo un error desconocido en Firebase. Por favor, intentalo de nuevo.';
      case 'invalid-custom-token':
        return 'El formato del token personalizado es incorrecto. Por favor, verifica tu token personalizado.';
      case 'custom-token-mismatch':
        return 'El token personalizado corresponde a una audiencia diferente.';
      case 'user-disabled':
        return 'La cuenta de usuario ha sido deshabilitada.';
      case 'user-not-found':
        return 'No se encontro ningun usuario para el correo electronico o UID proporcionado.';
      case 'invalid-email':
        return 'La direccion de correo electronico proporcionada es invalida. Por favor, ingresa un correo electronico valido.';
      case 'email-already-in-use':
        return 'La direccion de correo electronico ya esta registrada. Por favor, utiliza un correo electronico diferente.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Por favor, verifica tu contraseña e intenta de nuevo.';
      case 'weak-password':
        return 'La contraseña es demasiado debil. Por favor, elige una contraseña mas segura.';
      case 'provider-already-linked':
        return 'La cuenta ya esta vinculada con otro proveedor.';
      case 'operation-not-allowed':
        return 'Esta operacion no esta permitida. Contacta con soporte para obtener ayuda.';
      case 'invalid-credential':
        return 'La credencial proporcionada esta mal formada o ha expirado.';
      case 'invalid-verification-code':
        return 'Codigo de verificacion invalido. Por favor, ingresa un codigo valido.';
      case 'invalid-verification-id':
        return 'ID de verificacion invalido. Por favor, solicita un nuevo codigo de verificacion.';
      case 'captcha-check-failed':
        return 'La respuesta de reCAPTCHA no es valida. Por favor, intentalo de nuevo.';
      case 'app-not-authorized':
        return 'La aplicacion no esta autorizada para usar la Autenticacion de Firebase con la clave API proporcionada.';
      case 'keychain-error':
        return 'Se produjo un error en el llavero. Por favor, verifica el llavero e intentalo de nuevo.';
      case 'internal-error':
        return 'Se produjo un error de autenticacion interno. Por favor, intentalo de nuevo mas tarde.';
      case 'invalid-app-credential':
        return 'La credencial de la aplicacion es invalida. Por favor, proporciona una credencial de aplicacion valida.';
      case 'user-mismatch':
        return 'Las credenciales proporcionadas no corresponden al usuario que ha iniciado sesion previamente.';
      case 'requires-recent-login':
        return 'Esta operacion es sensible y requiere autenticacion reciente. Por favor, inicia sesion nuevamente.';
      case 'quota-exceeded':
        return 'Cuota excedida. Por favor, intentalo de nuevo mas tarde.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con el mismo correo electronico pero con credenciales de inicio de sesion diferentes.';
      case 'missing-iframe-start':
        return 'Falta la etiqueta de inicio del iframe en la plantilla de correo electronico.';
      case 'missing-iframe-end':
        return 'Falta la etiqueta de finalizacion del iframe en la plantilla de correo electronico.';
      case 'missing-iframe-src':
        return 'Falta el atributo src del iframe en la plantilla de correo electronico.';
      case 'auth-domain-config-required':
        return 'La configuracion authDomain es necesaria para el enlace de verificacion del codigo de accion.';
      case 'missing-app-credential':
        return 'Falta la credencial de la aplicacion. Por favor, proporciona credenciales de aplicacion validas.';
      case 'session-cookie-expired':
        return 'La cookie de sesion de Firebase ha expirado. Por favor, vuelve a iniciar sesion.';
      case 'uid-already-exists':
        return 'El ID de usuario proporcionado ya esta siendo utilizado por otro usuario.';
      case 'web-storage-unsupported':
        return 'El almacenamiento web no es compatible o esta deshabilitado.';
      case 'app-deleted':
        return 'Esta instancia de FirebaseApp ha sido eliminada.';
      case 'user-token-mismatch':
        return 'El token del usuario proporcionado no coincide con el ID de usuario autenticado.';
      case 'invalid-message-payload':
        return 'La carga util del mensaje de verificacion de plantilla de correo electronico es invalida.';
      case 'invalid-sender':
        return 'El remitente de la plantilla de correo electronico es invalido. Por favor, verifica el correo electronico del remitente.';
      case 'invalid-recipient-email':
        return 'La direccion de correo electronico del destinatario es invalida. Por favor, proporciona un correo electronico de destinatario valido.';
      case 'missing-action-code':
        return 'Falta el codigo de accion. Por favor, proporciona un codigo de accion valido.';
      case 'user-token-expired':
        return 'El token del usuario ha expirado y se requiere autenticacion. Por favor, inicia sesion nuevamente.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Credenciales de inicio de sesion no validas.';
      case 'expired-action-code':
        return 'El codigo de accion ha expirado. Por favor, solicita un nuevo codigo de accion.';
      case 'invalid-action-code':
        return 'El codigo de accion es invalido. Por favor, verifica el codigo e intentalo de nuevo.';
      case 'credential-already-in-use':
        return 'Esta credencial ya esta asociada con una cuenta de usuario diferente.';
      default:
        return 'Se produjo un error inesperado en Firebase. Por favor, intentalo de nuevo.';
    }
  }
}
