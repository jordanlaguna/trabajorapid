import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class THelperFunctions {
  static Color? getColor(String value) {
    //Aca se define el color que se va a retornar

    if (value == 'Green') {
      return Colors.green;
    } else if (value == 'Red') {
      return Colors.red;
    } else if (value == 'Blue') {
      return Colors.blue;
    } else if (value == 'Pink') {
      return Colors.pink;
    } else if (value == 'Grey') {
      return Colors.grey;
    } else if (value == 'Purple') {
      return Colors.purple;
    } else if (value == 'Black') {
      return Colors.black;
    } else if (value == 'White') {
      return Colors.white;
    } else if (value == 'Yellow') {
      return Colors.yellow;
    } else if (value == 'Orange') {
      return Colors.orange;
    } else if (value == 'Brown') {
      return Colors.brown;
    } else if (value == 'Cyan') {
      return Colors.cyan;
    } else if (value == 'Teal') {
      return Colors.teal;
    } else if (value == 'Indigo') {
      return Colors.indigo;
    } else {
      return null;
    }
  }

  //
  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  //mostrar alertas
  static void showAlert(String title, String message) {
    showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ok'),
              )
            ],
          );
        });
  }

  // navegar a otras ventanas
  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // truncar texto
  static String truncateText(String text, int maxlength) {
    if (text.length > maxlength) {
       return text;
    }else{
      return '${text.substring(0, maxlength)}...';
    }
  }

  // si esta en modo oscuro
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // para el tamaño de la pantalla
  static Size screenSize(){
    return MediaQuery.of(Get.context!).size;
  }

  // para la altura de la pantalla
  static double screenHeight(){
    return MediaQuery.of(Get.context!).size.height;
  }

  // para el ancho de la pantalla
  static double screenWidth(){
    return MediaQuery.of(Get.context!).size.width;
  }

  // para el formato de la fecha
  static String getFormattedDate(DateTime date, {String format = 'dd/MM/yyyy'}){
    return DateFormat(format).format(date);
  }
}
