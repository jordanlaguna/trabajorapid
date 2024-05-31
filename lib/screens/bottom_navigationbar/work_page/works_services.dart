import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/work_page/job.dart';

class FirebaseService {
  static Future<List<Job>> fetchJobs() async {
    final trabajosSnapshot = await FirebaseFirestore.instance
        .collection('trabajos')
        .where('estado', whereIn: ['Pendiente', 'En proceso'])
        .get();

    final List<Future<Job>> jobFutures = trabajosSnapshot.docs.map((doc) async {
      final jobId = doc['idEmpleo'];
      final serviciosSnapshot = await FirebaseFirestore.instance
          .collection('servicios')
          .doc(jobId)
          .get();

      final jobData = {
        ...doc.data(),
        ...serviciosSnapshot.data()!,
      };

      return Job.fromFirestore(jobData);
    }).toList();

    return await Future.wait(jobFutures);
  }
}