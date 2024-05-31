// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Job {
  final String id; // Campo id
  final String tipoOferta;
  final String tipoServicio;
  final String detalles;
  String estado; // Cambiar a no final
  final String fecha;
  final String uidEmisor;
  final String nameReceptor;
  final String nameEmisor;
  final String pago;
  final String direccion;

  Job({
    required this.id, // Campo id
    required this.tipoOferta,
    required this.tipoServicio,
    required this.detalles,
    required this.estado,
    required this.uidEmisor,
    required this.fecha,
    required this.nameReceptor,
    required this.nameEmisor,
    required this.pago,
    required this.direccion,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp;
    final DateTime dateTime = timestamp.toDate();
    final String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

    return Job(
      id: doc.id, // Asignar el id del documento
      tipoOferta: data['tipoOferta'] ?? '',
      tipoServicio: data['tipoServicio'] ?? '',
      detalles: data['contenido'] ?? '',
      estado: data['estado'] ?? '',
      uidEmisor: data['uidEmisor'] ?? '',
      fecha: formattedDate,
      nameReceptor: data['titulo'] ?? '',
      nameEmisor: data['emisorNombre'] ?? '',
      pago: data['pago'] ?? '',
      direccion: data['direccion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipoOferta': tipoOferta,
      'tipoServicio': tipoServicio,
      'detalles': detalles,
      'estado': estado,
      'uidEmisor': uidEmisor,
      'timestamp': Timestamp.fromDate(DateFormat('dd-MM-yyyy').parse(fecha)),
      'nameReceptor': nameReceptor,
      'nameEmisor': nameEmisor,
      'pago': pago,
      'direccion': direccion,
    };
  }
}
