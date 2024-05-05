class TFirebaseAuthException implements Exception {
  final String code;
  TFirebaseAuthException(this.code);

  String get message {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo ya esta en uso';
      case 'invalid-email':
        return 'Correo invalido. Por favor, ingrese un correo valido';
      case 'weak-password':
        return 'La contraseña es muy debil';
      case 'user-disabled':
        return 'El usuario ha sido deshabilitado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta. Por favor, intente de nuevo';
      case 'invalid-verification-code':
        return 'Codigo de verificacion invalido. Por favor, intente de nuevo';
      case 'invalid-verification-id':
        return 'ID de verificacion invalido. Por favor, intente de nuevo';
      case 'quota-exceeded':
        return 'Se ha excedido el limite de solicitudes. Por favor, intente mas tarde';
      case 'email-already-exists':
        return 'El correo ya esta en uso. Por use otro correo';
      case 'provider-already-linked':
        return 'El proveedor ya esta vinculado a otra cuenta';
      case 'requires-recent-login':
        return 'Esta accion requiere que inicie sesion nuevamente';
      case 'credential-already-in-use':
        return 'Esta credencial ya esta en uso en otra cuenta. Por favor, use otra credencial';
      case 'user-mismatch':
        return 'El usuario no coincide con la credencial';
      case 'account-exists-with-different-credential':
        return 'La cuenta ya existe con una credencial diferente';
      case 'operation-not-allowed':
        return 'Esta operacion no esta permitida';
      case 'expired-action-code':
        return 'El codigo de accion ha expirado. Por favor, solicite un nuevo codigo';
      case 'invalid-action-code':
        return 'El codigo de accion es invalido. Por favor, verifique el codigo';
      case 'missing-action-code':
        return 'Falta el codigo de accion. Por favor, verifique el codigo';
      case 'user-token-expired':
        return 'El token del usuario ha expirado. Por favor, inicie sesion nuevamente';
      case 'invalid-credential':
        return 'Credencial invalida. Por favor, verifique la credencial';
      case 'user-token-revoked':
        return 'El token del usuario ha sido revocado. Por favor, inicie sesion nuevamente';
      case 'invalid-message-payload':
        return 'Carga util de mensaje invalida';
      case 'invalid-sender':
        return 'Remitente invalido';
      case 'invalid-recipient-email':
        return 'Correo del destinatario invalido';
      case 'missing-iframe-src':
        return 'A la plantilla de correo electrónico le falta la etiqueta de inicio';
      case 'auth-domain-config-required':
        return 'La configuración del dominio de autenticación no está configurada en la consola de Firebase.Debe configurar la configuración del dominio de autenticación en la consola de Firebase para habilitar la autenticación con proveedores de identidad externos.';
      case 'missing-app-credential':
        return 'Falta la credencial de la aplicación. Proporcione una credencial de la aplicación válida';
      case 'invalid-app-credential':
        return 'Credencial de aplicación no válida';
      case 'session-cookie-expired':
        return 'La cookie de sesión ha expirado';
      case 'uid-already-exists':
        return 'El uid ya existe';
      case 'invalid-cordova-configuration':
        return 'Configuración de cordova no válida';
      case 'app-deleted':
        return 'La aplicación ha sido eliminada';
      case 'user-token-mismatch':
        return 'El token del usuario no coincide';
      case 'web-storage-unsupported':
        return 'El almacenamiento web no es compatible';
      case 'app-not-authorized':
        return 'La aplicación no está autorizada para usar Firebase Authentication con el proveedor solicitado';
      case 'keychain-error':
        return 'Se ha producido un error en el llavero. Compruebe el llavero e inténtelo de nuevo.';
      case 'internal-error':
        return 'Error interno';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Credenciales de inicio de sesión no válidas';
      default:
        return 'Ha ocurrido un error inesperado';
    }
  }
}
