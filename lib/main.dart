import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/tareas_repository.dart';
import 'screens/tareas_page.dart';

void main() {
  // Archivo SQLite persistente (en el directorio de datos de la app).
  final db = AppDatabase(
    driftDatabase(
      name: 'gestor_tareas',
      // Archivos de web/ (solo se usan en el navegador).
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  runApp(GestorTareasApp(repositorio: TareasRepository(db)));
}

/// Punto de entrada de la aplicación. Recibe el repositorio para poder
/// sustituir la base por una en memoria en las pruebas.
class GestorTareasApp extends StatelessWidget {
  const GestorTareasApp({super.key, required this.repositorio});

  final TareasRepository repositorio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(repositorio: repositorio),
    );
  }
}
