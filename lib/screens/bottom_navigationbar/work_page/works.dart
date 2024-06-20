// ignore_for_file: library_private_types_in_public_api

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/services/chat/chat_services.dart';
import 'works_services.dart';
import 'job.dart';
import 'badge_status.dart';

class WorksPage extends StatefulWidget {
  const WorksPage({Key? key}) : super(key: key);

  static final GlobalKey<_WorksPageState> pageKey =
      GlobalKey<_WorksPageState>();

  @override
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
  final ChatServices _chatServices = ChatServices();
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

  Color getBadgeColor(String estado) {
    switch (estado) {
      case 'Cancelado':
        return Colors.redAccent;
      case 'Pendiente':
        return Colors.orangeAccent;
      case 'En proceso':
        return Colors.blueAccent;
      case 'Terminado':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
      final estadoTrabajo = trabajo.estado.toLowerCase();
      return tituloTrabajo.contains(input) &&
          (selectedFilter.toLowerCase() == 'todos' ||
              estadoTrabajo == selectedFilter.toLowerCase());
    }).toList();

    // Ordenar por fecha descendente
    resultados.sort((a, b) => b.fechaDateTime.compareTo(a.fechaDateTime));

    setState(() {
      trabajosFiltrados = resultados;
      showAll = false;
    });
  }

  void showJobDetails(Job job) {
    final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.work,
                  color: Colors.blueAccent,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  job.tipoServicio,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Divider(),
                _buildInfoTile(Icons.person, 'Encargado', job.nameReceptor),
                _buildInfoTile(
                    Icons.local_offer, 'Tipo de oferta', job.tipoOferta),
                _buildInfoTile(
                    Icons.build, 'Tipo de servicio', job.tipoServicio),
                _buildInfoTile(Icons.details, 'Detalles', job.detalles),
                _buildInfoTile(Icons.location_on, 'Dirección', job.direccion),
                _buildInfoTile(Icons.timeline, 'Estado', job.estado),
                _buildInfoTile(Icons.person_pin, 'Interesado', job.nameEmisor),
                _buildInfoTile(Icons.attach_money, 'Precio', job.pago),
                _buildInfoTile(Icons.date_range, 'Fecha', job.fecha),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ),
            if (job.uidEmisor == currentUserUid &&
                job.estado != 'Terminado' &&
                job.estado != 'Cancelado') ...[
              Center(
                child: TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  onPressed: () {
                    showConfirmationDialog(
                      context,
                      '¿Seguro que quiere cancelar la oferta?',
                      () {
                        updateJobStatus(job, 'Cancelado');
                        Navigator.of(dialogContext)
                            .pop(); // Cerrar el diálogo principal
                      },
                    );
                  },
                ),
              ),
              Center(
                child: TextButton(
                  child: const Text(
                    'Terminar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    showConfirmationDialog(
                      context,
                      '¿Seguro que quiere terminar la oferta?',
                      () {
                        updateJobStatus(job, 'Terminado');
                        Navigator.of(dialogContext)
                            .pop(); // Cerrar el diálogo principal
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> updateJobStatus(Job job, String newStatus) async {
    await FirebaseService.updateJobStatus(job.id, newStatus);

    setState(() {
      job.estado = newStatus;
      aplicarFiltros(); // Vuelve a aplicar filtros para actualizar la lista
    });

    String message = 'La oferta ha sido $newStatus.';
    if (newStatus == 'Cancelado') {
      message = 'La oferta de $job.tipoServicio ha sido cancelada';
    } else if (newStatus == 'Terminado') {
      message = 'La oferta ha sido completada';
    }

    try {
      await _chatServices.sendMessage(job.uidReceptor, message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar mensaje: $e')),
      );
    }
  }

  void showConfirmationDialog(
      BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Confirmación'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Sí',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int itemCount =
        showAll ? trabajosFiltrados.length : min(trabajosFiltrados.length, 7);
    return Scaffold(
      backgroundColor: Colors.blue[50],
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
                ? Colors.orangeAccent
                : Colors.blueAccent;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(job.tipoServicio,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    BadgeStatus(
                        text: job.estado, color: getBadgeColor(job.estado)),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.work,
                  color: Colors.blueAccent,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  job.tipoServicio,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Divider(),
                _buildInfoTile(Icons.person, 'Encargado', job.nameReceptor),
                _buildInfoTile(
                    Icons.local_offer, 'Tipo de oferta', job.tipoOferta),
                _buildInfoTile(
                    Icons.build, 'Tipo de servicio', job.tipoServicio),
                _buildInfoTile(Icons.details, 'Detalles', job.detalles),
                _buildInfoTile(Icons.location_on, 'Dirección', job.direccion),
                _buildInfoTile(Icons.timeline, 'Estado', job.estado),
                _buildInfoTile(Icons.person_pin, 'Interesado', job.nameEmisor),
                _buildInfoTile(Icons.attach_money, 'Precio', job.pago),
                _buildInfoTile(Icons.date_range, 'Fecha', job.fecha),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
