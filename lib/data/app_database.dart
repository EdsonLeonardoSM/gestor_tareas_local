import 'package:drift/drift.dart';

import '../models/tarea.dart';

part 'app_database.g.dart';

// Tabla de tareas; Drift devuelve objetos Tarea directamente.
@UseRowClass(Tarea)
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get titulo => text().withLength(min: 1, max: maxLongitudTitulo)();

  // SQLite guarda el booleano como 0/1.
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
