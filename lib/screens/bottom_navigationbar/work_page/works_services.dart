import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/work_page/job.dart';

class FirebaseService {
  static Future<List<Job>> fetchJobs() async {
    final trabajosSnapshot = await FirebaseFirestore.instance
        .collection('trabajos')
        .where('estado', whereIn: ['Pendiente', 'En proceso']).get();

    final List<Job> jobs = trabajosSnapshot.docs.map((doc) {
      return Job.fromFirestore(doc);
    }).toList();

    return jobs;
  }

  static Future<void> updateJobStatus(String jobId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('trabajos')
        .doc(jobId)
        .update({'estado': newStatus});
  }
}
