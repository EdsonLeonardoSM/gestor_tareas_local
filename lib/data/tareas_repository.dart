import 'package:drift/drift.dart';

import '../models/tarea.dart';
import 'app_database.dart';

// Acceso a la base de datos.
class TareasRepository {
  TareasRepository(this._db);

  final AppDatabase _db;

  // SELECT reactivo: emite la lista cada vez que la tabla cambia.
  Stream<List<Tarea>> observarTareas() {
    final consulta = _db.select(_db.tareas)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return consulta.watch();
  }

  // INSERT
  Future<int> crear(String titulo) {
    final error = validarTitulo(titulo);
    if (error != null) throw ArgumentError(error);
    return _db
        .into(_db.tareas)
        .insert(TareasCompanion.insert(titulo: titulo.trim()));
  }

  // UPDATE del título
  Future<void> actualizarTitulo(int id, String titulo) async {
    final error = validarTitulo(titulo);
    if (error != null) throw ArgumentError(error);
    await (_db.update(_db.tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(titulo: Value(titulo.trim())),
    );
  }

  // UPDATE del estado
  Future<void> cambiarEstado(int id, bool completada) async {
    await (_db.update(_db.tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(completada: Value(completada)),
    );
  }

  // DELETE por id
  Future<void> eliminar(int id) async {
    await (_db.delete(_db.tareas)..where((t) => t.id.equals(id))).go();
  }
}
