import 'package:flutter/material.dart';

class WorkPage extends StatelessWidget {
  const WorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Trabajos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 65, 111, 223),
                Color.fromARGB(255, 110, 174, 231),
              ],
            ),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Trabajos Realizados',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: Color.fromARGB(255, 46, 77, 142),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50, // Ajusta esta posición según sea necesario
            left: 0,
            right: 0,
            bottom: 0,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                return false;
              },
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: jobs.map((job) {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                job.name,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.status,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    job.date,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Aquí puedes agregar la funcionalidad que desees cuando se pulse en un elemento de la lista
                              },
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 0.0,
                            thickness: 2.0,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<Job> jobs = [
  Job('Trabajo 1', 'Terminado', '2023-01-01'),
  Job('Trabajo 2', 'Terminado', '2023-02-01'),
  Job('Trabajo 3', 'Terminado', '2023-03-01'),
  Job('Trabajo 4', 'Terminado', '2023-04-01'),
  Job('Trabajo 5', 'Terminado', '2023-05-01'),
  Job('Trabajo 6', 'Terminado', '2023-06-01'),
  Job('Trabajo 7', 'Terminado', '2023-07-01'),
  Job('Trabajo 8', 'Terminado', '2023-08-01'),
];

class Job {
  final String name;
  final String status;
  final String date;

  Job(this.name, this.status, this.date);
}
