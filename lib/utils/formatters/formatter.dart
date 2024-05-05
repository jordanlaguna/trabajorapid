import 'package:intl/intl.dart';

class TFormatter{
  static String formatDate(DateTime? date){
    date ??= DateTime.now();
    return DateFormat('dd/MM/yyyy').format(date); //formato de fecha dd/MM/yyyy
  }

  static String formatCurrency(double amount){
    //formato de moneda para Costa Rica
    return NumberFormat.currency(locale: 'es_CR', symbol: '₡').format(amount); //formato de moneda del pais
  }

  static String formatPhoneNumber(String phoneNumber){
    // formato de numero de telefono del pais +506 8888-8888
    if(phoneNumber.length == 8){
      return '+506 ${phoneNumber.substring(0, 4)}-${phoneNumber.substring(4)}';
    }
    return phoneNumber;
  }

  // luego aca se pueden hacer validaciones a otros tipos de formato de numeros de telefonos
}