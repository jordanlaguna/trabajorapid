// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Job {
  final String tipoOferta;
  final String tipoServicio;
  final String detalles;
  final String estado;
  final String fecha;

  Job({
    required this.tipoOferta,
    required this.tipoServicio,
    required this.detalles,
    required this.estado,
    required this.fecha,
  });

  factory Job.fromFirestore(Map<String, dynamic> data) {
    final timestamp = data['timestamp'] as Timestamp;
    final DateTime dateTime = timestamp.toDate();
    final String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

    return Job(
      tipoOferta: data['tipoOferta'] ?? '',
      tipoServicio: data['tipoServicio'] ?? '',
      detalles: data['contenido'] ?? '',
      estado: data['estado'] ?? '',
      fecha: formattedDate,
    );
  }
}