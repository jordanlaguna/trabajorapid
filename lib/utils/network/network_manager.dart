import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/utils/constans/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  // Inicializar la conexión
  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Actualizar el estado de la conexión y mostrar un popup si no hay conexión
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    _connectionStatus.value = results.first;
    if (_connectionStatus.value == ConnectivityResult.none) {
        // Mostrar notificación de no conexión
        TLoaders.customToast(message: 'No tienes conexión a internet');
    }
  }

    // Verifica si hay conexion a internet
  Future<bool> isConnected() async {
    try{
      final result = await _connectivity.checkConnectivity();
      // ignore: unrelated_type_equality_checks
      if(result == ConnectivityResult.none){
        return false;
      }else{
        return true;
      }
    }on PlatformException catch(_){
      return false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
