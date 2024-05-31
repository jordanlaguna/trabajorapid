import 'dart:math';
import 'package:flutter/material.dart';
import 'works_services.dart';
import 'job.dart';
import 'badge_status.dart';

class WorksPage extends StatefulWidget {
  const WorksPage({Key? key}) : super(key: key);

  // ignore: library_private_types_in_public_api
  static final GlobalKey<_WorksPageState> pageKey = GlobalKey<_WorksPageState>();

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

  List<Job> trabajos = [];

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    final List<Job> fetchedJobs = await FirebaseService.fetchJobs();

    setState(() {
      trabajos = fetchedJobs;
      aplicarFiltros();
    });
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
      final tituloTrabajo = trabajo.tipoServicio.toLowerCase();
      final input = searchQuery.toLowerCase();
      return tituloTrabajo.contains(input);
    }).toList();

    if (selectedFilter.toLowerCase() != 'todos') {
      resultados = resultados.where((trabajo) {
        return trabajo.estado.toLowerCase() == selectedFilter.toLowerCase();
      }).toList();
    }

    setState(() {
      trabajosFiltrados = resultados;
      showAll = false; // Reinicia showAll
    });
  }

  void showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            job.tipoServicio,
            style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tipo de oferta: ${job.tipoOferta}'),
                Text('Tipo de servicio: ${job.tipoServicio}'),
                Text('Detalles: ${job.detalles}'),
                Text('Estado: ${job.estado}'),
                Text('Fecha: ${job.fecha}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = showAll ? trabajosFiltrados.length : min(trabajosFiltrados.length, 7);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: itemCount + 1,
          itemBuilder: (context, index) {
            if (index == itemCount) {
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
                return const SizedBox.shrink();
              }
            }
            final job = trabajosFiltrados[index];
            final Color badgeColor = job.estado == 'Pendiente'
                ? Colors.redAccent
                : Colors.blueAccent;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(job.tipoServicio, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    BadgeStatus(text: job.estado, color: badgeColor),
                    const SizedBox(width: 8.0),
                    Text(job.fecha),
                  ],
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
            return job.tipoServicio.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion.tipoServicio),
          subtitle: Text('${suggestion.estado} • ${suggestion.fecha}'),
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
          title: Text(job.tipoServicio),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tipo de oferta: ${job.tipoOferta}'),
                Text('Tipo de servicio: ${job.tipoServicio}'),
                Text('Detalles: ${job.detalles}'),
                Text('Estado: ${job.estado}'),
                Text('Fecha: ${job.fecha}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
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