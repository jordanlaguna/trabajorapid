class TValidator{
  // Validar campos vacíos
  static String? validateEmptyText(String? fieldname, String? value){
    if(value == null || value.isEmpty){
      return '$fieldname requerido';
    }
    return null;
  }

  // Validar el correo electrónico
  static String? validateEmail(String? value){
    if(value == null || value.isEmpty){
      return 'Correo electrónico requerido';
    }

    // Expresion regular para validar un correo electronico
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if(!emailRegExp.hasMatch(value)){
      return 'Correo electrónico inválido';
    }
    return null;
  }

  // Validar la contraseña
  static String? validatePassword(String? value){
    if(value == null || value.isEmpty){
      return 'Contraseña requerida';
    }
    // La contraseña debe tener al menos 6 caracteres
    if(value.length < 6){
      return 'La contraseña debe tener al menos 6 caracteres';
    }
   
    // La contraseña debe tener al menos una letra mayúscula
    if(!value.contains(RegExp(r'[A-Z]'))){
      return 'La contraseña debe tener al menos una letra mayúscula';
    }

    // La contraseña debe tener al menos un número
    if(!value.contains(RegExp(r'[0-9]'))){
      return 'La contraseña debe tener al menos un número';
    }

    // La contraseña debe tener al menos un caracter especial
    if(!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))){
      return 'La contraseña debe tener al menos un caracter especial';
    }
    return null;
  }

  // validar el numero de telefono
  static String? validatePhoneNumber(String? value){
    if(value == null || value.isEmpty){
      return 'Número de teléfono requerido';
    }

    // Expresion regular para validar un número de teléfono
    final phoneRegExp = RegExp(r'^\d{8}$');

    if(!phoneRegExp.hasMatch(value)){
      return 'Número de teléfono inválido (Debe tener 8 dígitos)';
    }
    return null;
  }
}