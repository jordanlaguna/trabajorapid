import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/work_page/job.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static Future<List<Job>> fetchJobs() async {
    // Obtiene el uid del usuario actual
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    // Consulta para trabajos donde uidEmisor es igual al uid del usuario actual
    final trabajosEmisorSnapshot = await FirebaseFirestore.instance
        .collection('trabajos')
        .where('estado',
            whereIn: ['Cancelado', 'Pendiente', 'En proceso', 'Terminado'])
        .where('uidEmisor', isEqualTo: uid)
        .get();

    // Consulta para trabajos donde uidReceptor es igual al uid del usuario actual
    final trabajosReceptorSnapshot = await FirebaseFirestore.instance
        .collection('trabajos')
        .where('estado',
            whereIn: ['Cancelado', 'Pendiente', 'En proceso', 'Terminado'])
        .where('uidReceptor', isEqualTo: uid)
        .get();

    // Combina los resultados de ambas consultas
    final List<Job> jobs = [
      ...trabajosEmisorSnapshot.docs.map((doc) => Job.fromFirestore(doc)),
      ...trabajosReceptorSnapshot.docs.map((doc) => Job.fromFirestore(doc)),
    ];

    return jobs;
  }

  static Future<void> updateJobStatus(String jobId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('trabajos')
        .doc(jobId)
        .update({'estado': newStatus});
  }
}
