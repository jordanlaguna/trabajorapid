class TFormatException implements Exception {
  final String message;

  const TFormatException([this.message = 'Se produjo un error de formato inesperado. Por favor, verifica tu entrada.']);

  factory TFormatException.fromMessage(String message) {
    return TFormatException(message);
  }

  String get formattedMessage => message;

  factory TFormatException.fromCode(String code) {
    switch (code) {
      case 'invalid-email-format':
        return const TFormatException('El formato de la direccion de correo electronico es invalido. Por favor, ingresa un correo electronico valido.');
      case 'invalid-phone-number-format':
        return const TFormatException('El formato del numero de telefono proporcionado es invalido. Por favor, ingresa un numero valido.');
      case 'invalid-date-format':
        return const TFormatException('El formato de fecha es invalido. Por favor, ingresa una fecha valida.');
      case 'invalid-url-format':
        return const TFormatException('El formato de la URL es invalido. Por favor, ingresa una URL valida.');
      case 'invalid-credit-card-format':
        return const TFormatException('El formato de la tarjeta de credito es invalido. Por favor, ingresa un numero de tarjeta de credito valido.');
      case 'invalid-numeric-format':
        return const TFormatException('La entrada debe tener un formato numerico valido.');
      default:
        return const TFormatException();
    }
  }
}
