import 'package:flutter/material.dart';

class WorksPage extends StatefulWidget {
  const WorksPage({super.key});

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  String searchQuery = '';
  String selectedFilter = 'Todos';
  int itemsToShow = 8;

  List<Job> get filteredJobs {
    List<Job> filtered = jobs.where((job) {
      return job.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.detail.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (selectedFilter != 'Todos') {
      filtered = filtered.where((job) => job.status == selectedFilter).toList();
    }

    return filtered;
  }

  void toggleItems() {
    setState(() {
      if (itemsToShow >= filteredJobs.length) {
        itemsToShow = 8;
      } else {
        itemsToShow += 8;
      }
    });
  }

  void showModal(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Detalles del servicio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Nombre: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: job.name,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Precio: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '\$${job.price}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Detalle: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: job.detail,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 90,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Color.fromARGB(255, 65, 111, 223),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Job> jobsToShow = filteredJobs.take(itemsToShow).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trabajos Realizados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: JobSearchDelegate(jobs, showModal),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                selectedFilter = value;
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return <String>['Todos', 'Terminado', 'Pendiente']
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Historial de Trabajos',
                      style: TextStyle(
                        color: Color.fromARGB(255, 46, 77, 142),
                        fontSize: 24,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 70,
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
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      ...jobsToShow.map((job) {
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
                                trailing: const Text(
                                  'Ver Detalles',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Montserrat",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.solid,
                                    decorationThickness: 1.5,
                                    height: 2.0,
                                  ),
                                ),
                                onTap: () {
                                  showModal(context, job);
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
                      if (filteredJobs.length > itemsToShow || itemsToShow > 8)
                        const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: toggleItems,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 90,
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            itemsToShow >= filteredJobs.length
                                ? 'Mostrar menos'
                                : 'Cargar más',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 111, 223),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class JobSearchDelegate extends SearchDelegate<String> {
  final List<Job> jobs;
  final Function(BuildContext, Job) showModal;

  JobSearchDelegate(this.jobs, this.showModal);

  @override
  String? get searchFieldLabel => 'Buscar...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Job> results = jobs.where((job) {
      return job.name.toLowerCase().contains(query.toLowerCase()) ||
          job.detail.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final Job job = results[index];
        return ListTile(
          title: Text(job.name),
          subtitle: Text(job.detail),
          onTap: () {
            showModal(context, job);
            close(context, '');
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Job> suggestions = jobs.where((job) {
      return job.name.toLowerCase().contains(query.toLowerCase()) ||
          job.detail.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final Job job = suggestions[index];
        return ListTile(
          title: Text(job.name),
          subtitle: Text(job.detail),
          onTap: () {
            query = job.name;
            showResults(context);
          },
        );
      },
    );
  }
}

final List<Job> jobs = [
  Job('Transporte', 'Terminado', '2023-01-01', 100.0,
      'Servicio de viajes de carga'),
  Job('Mecánica', 'Terminado', '2023-02-01', 150.0,
      'Servicio de reparación de vehículos'),
  Job('Asistente', 'Terminado', '2023-03-01', 200.0, 'Servicio de asistente'),
  Job('Manicura', 'Terminado', '2023-04-01', 250.0, 'Servicio de uñas'),
  Job('Limpieza', 'Terminado', '2023-05-01', 300.0, 'Servicio de limpieza'),
  Job('Jardinería', 'Terminado', '2023-06-01', 350.0, 'Servicio de jardinería'),
  Job('Pintura', 'Terminado', '2023-07-01', 400.0,
      'Servicio de pintura de casas'),
  Job('Mudanza', 'Terminado', '2023-08-01', 450.0, 'Servicio de mudanza'),
  Job('Electricidad', 'Terminado', '2023-09-01', 500.0,
      'Servicio de reparación eléctrica'),
  Job('Fontanería', 'Terminado', '2023-10-01', 550.0,
      'Servicio de reparación de fontanería'),
  Job('Albañilería', 'Terminado', '2023-11-01', 600.0,
      'Servicio de albañilería'),
  Job('Cocina', 'Terminado', '2023-12-01', 650.0, 'Servicio de chef privado'),
];

class Job {
  final String name;
  final String status;
  final String date;
  final double price;
  final String detail;

  Job(this.name, this.status, this.date, this.price, this.detail);
}
