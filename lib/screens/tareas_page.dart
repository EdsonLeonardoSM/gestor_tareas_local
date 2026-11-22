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
      _mostrarMensaje('No se pudo guardar la tarea. Intenta de nuevo.');
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await widget.repositorio.cambiarEstado(tarea.id, completada);
    } catch (e) {
      _mostrarMensaje('No se pudo actualizar la tarea.');
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {
    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (context) => _EditarTituloDialog(tituloActual: tarea.titulo),
    );
    if (nuevoTitulo == null) return;
    try {
      await widget.repositorio.actualizarTitulo(tarea.id, nuevoTitulo);
    } catch (e) {
      _mostrarMensaje('No se pudo editar la tarea.');
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await widget.repositorio.eliminar(tarea.id);
    } catch (e) {
      _mostrarMensaje('No se pudo eliminar la tarea.');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
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
              onChanged: (_) {
                if (_errorTitulo != null) setState(() => _errorTitulo = null);
              },
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

class _EditarTituloDialog extends StatefulWidget {
  const _EditarTituloDialog({required this.tituloActual});

  final String tituloActual;

  @override
  State<_EditarTituloDialog> createState() => _EditarTituloDialogState();
}

class _EditarTituloDialogState extends State<_EditarTituloDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tituloActual);
  }

  void _guardar() {
    final error = validarTitulo(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar tarea'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: maxLongitudTitulo,
        onSubmitted: (_) => _guardar(),
        decoration: InputDecoration(errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
