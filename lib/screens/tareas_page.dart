import 'package:flutter/material.dart';

import '../data/tareas_repository.dart';
import '../models/tarea.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({super.key, required this.repositorio});

  final TareasRepository repositorio;

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  // El stream se crea una vez aquí, no dentro de build().
  late final Stream<List<Tarea>> _tareas;
  String? _errorTitulo;

  @override
  void initState() {
    super.initState();
    _tareas = widget.repositorio.observarTareas();
  }

  Future<void> _agregarTarea() async {
    final error = validarTitulo(_tituloController.text);
    if (error != null) {
      setState(() => _errorTitulo = error);
      return;
    }
    try {
      await widget.repositorio.crear(_tituloController.text);
      _tituloController.clear();
      if (mounted) setState(() => _errorTitulo = null);
    } catch (e) {
      if (mounted) _pendiente('No se pudo guardar la tarea. Intenta de nuevo.');
    }
  }

  void _alternarCompletada(Tarea tarea, bool completada) {
    _pendiente('Implementar actualización de tarea');
  }

  void _editarTarea(Tarea tarea) {
    _pendiente('Implementar edición de título');
  }

  void _eliminarTarea(Tarea tarea) {
    _pendiente('Implementar eliminación de tarea');
  }

  void _pendiente(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              maxLength: maxLongitudTitulo,
              onSubmitted: (_) => _agregarTarea(),
              decoration: InputDecoration(
                labelText: 'Nueva tarea',
                border: const OutlineInputBorder(),
                errorText: _errorTitulo,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Tarea>>(
                stream: _tareas,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('No se pudieron leer las tareas guardadas'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tareas = snapshot.data!;
                  if (tareas.isEmpty) {
                    return const Center(
                      child: Text('Todavía no hay tareas guardadas'),
                    );
                  }
                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: tarea.completada,
                            onChanged: (valor) {
                              if (valor != null) {
                                _alternarCompletada(tarea, valor);
                              }
                            },
                          ),
                          title: Text(tarea.titulo),
                          subtitle: Text('ID: ${tarea.id}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarTarea(tarea),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminarTarea(tarea),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
