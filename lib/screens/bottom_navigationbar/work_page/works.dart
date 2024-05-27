import 'dart:math';

import 'package:flutter/material.dart';

class Job {
  final String name;
  final String status;
  final String date;
  final double price;
  final String detail;

  Job(this.name, this.status, this.date, this.price, this.detail);
}

class WorksPage extends StatefulWidget {
  const WorksPage({Key? key}) : super(key: key);

  // ignore: library_private_types_in_public_api
  static final GlobalKey<_WorksPageState> pageKey =
      GlobalKey<_WorksPageState>();

  @override
  // ignore: library_private_types_in_public_api
  _WorksPageState createState() => _WorksPageState();

  static void showJobSearch(BuildContext context) {
    final state = pageKey.currentState;
    if (state != null) {
      showSearch(
        context: context,
        delegate: JobSearchDelegate(state.buscarTrabajos, state.trabajos),
      );
    }
  }
}

class _WorksPageState extends State<WorksPage> {
  String searchQuery = '';
  String selectedFilter = 'Todos';
  List<Job> trabajosFiltrados = [];
  bool showAll = false;
  final TextStyle pendingStyle = const TextStyle(color: Colors.redAccent);
  final TextStyle inProcessStyle = const TextStyle(color: Colors.blueAccent);

  final List<Job> trabajos = [
    Job('Transporte', 'En Proceso', '2023-01-01', 100.0,
        'Servicio de viajes de carga'),
    Job('Mecánica', 'Pendiente', '2023-02-01', 150.0,
        'Servicio de reparación de vehículos'),
    Job('Asistente', 'En Proceso', '2023-03-01', 200.0,
        'Servicio de asistente'),
    Job('Manicura', 'En Proceso', '2023-04-01', 250.0, 'Servicio de uñas'),
    Job('Limpieza', 'Pendiente', '2023-05-01', 300.0, 'Servicio de limpieza'),
    Job('Jardinería', 'En Proceso', '2023-06-01', 350.0,
        'Servicio de jardinería'),
    Job('Pintura', 'En Proceso', '2023-07-01', 400.0,
        'Servicio de pintura de casas'),
    Job('Carpintería', 'Pendiente', '2023-08-01', 450.0,
        'Servicio de reparación de muebles'),
    Job('Electricidad', 'En Proceso', '2023-09-01', 500.0,
        'Servicio de reparación de instalaciones eléctricas'),
    Job('Plomería', 'En Proceso', '2023-10-01', 550.0,
        'Servicio de reparación de tuberías'),
    Job('Cerrajería', 'Pendiente', '2023-11-01', 600.0,
        'Servicio de reparación de cerraduras'),
    Job('Cocina', 'En Proceso', '2023-12-01', 650.0, 'Servicio de cocina'),
  ];

  @override
  void initState() {
    super.initState();
    aplicarFiltros();
  }

  void showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(job.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Status: ${job.status}'),
                Text('Date: ${job.date}'),
                Text('Price: \$${job.price.toStringAsFixed(2)}'),
                Text('Details: ${job.detail}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void buscarTrabajos(String query) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        searchQuery = query;
        aplicarFiltros();
      });
    });
  }

  void filtrarTrabajos(String estado) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedFilter = estado;
        aplicarFiltros();
      });
    });
  }

  void resetFiltro() {
    setState(() {
      searchQuery = '';
      selectedFilter = 'Todos';
      aplicarFiltros();
    });
  }

  void aplicarFiltros() {
    List<Job> resultados = trabajos.where((trabajo) {
      final tituloTrabajo = trabajo.name.toLowerCase();
      final input = searchQuery.toLowerCase();
      return tituloTrabajo.contains(input);
    }).toList();

    if (selectedFilter.toLowerCase() != 'todos') {
      resultados = resultados.where((trabajo) {
        return trabajo.status.toLowerCase() == selectedFilter.toLowerCase();
      }).toList();
    }

    setState(() {
      trabajosFiltrados = resultados;
      showAll = false; // Reinicia showAll
    });
  }

  @override
  Widget build(BuildContext context) {
    // La cantidad de ítems se ajusta según si showAll es true o false
    int itemCount =
        showAll ? trabajosFiltrados.length : min(trabajosFiltrados.length, 7);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: itemCount + 1, // Se agrega uno para el botón "Mostrar más"
          itemBuilder: (context, index) {
            if (index == itemCount) {
              // Si es el ítem del botón "Mostrar más"
              if (!showAll && trabajosFiltrados.length > 7) {
                return Center(
                  child: TextButton(
                    child: const Text("Mostrar más"),
                    onPressed: () {
                      setState(() {
                        showAll = true;
                      });
                    },
                  ),
                );
              } else {
                return const SizedBox
                    .shrink(); // No mostrar botón si ya están todos visibles
              }
            }
            final job = trabajosFiltrados[index];
            TextStyle statusStyle =
                job.status == 'Pendiente' ? pendingStyle : inProcessStyle;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(job.name),
                subtitle: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.black), // Estilo base para el texto
                    children: <TextSpan>[
                      TextSpan(text: '${job.status} • ', style: statusStyle),
                      TextSpan(text: job.date), // Fecha sin estilo especial
                    ],
                  ),
                ),
                trailing: TextButton(
                  child: const Text('Ver Detalles'),
                  onPressed: () => showJobDetails(job),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class JobSearchDelegate extends SearchDelegate<String> {
  final Function(String) buscarTrabajos;
  final List<Job> trabajos;

  JobSearchDelegate(this.buscarTrabajos, this.trabajos);

  @override
  String? get searchFieldLabel => 'Buscar trabajos';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
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
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? trabajos
        : trabajos.where((job) {
            return job.name.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion.name),
          subtitle: Text('${suggestion.status} • ${suggestion.date}'),
          onTap: () {
            showJobDetails(context, suggestion);
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  void showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(job.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Status: ${job.status}'),
                Text('Date: ${job.date}'),
                Text('Price: \$${job.price.toStringAsFixed(2)}'),
                Text('Details: ${job.detail}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}