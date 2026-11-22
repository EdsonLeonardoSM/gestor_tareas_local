import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:gestor_tareas_local/data/tareas_repository.dart';
import 'package:gestor_tareas_local/models/tarea.dart';

void main() {
  group('validarTitulo', () {
    test('rechaza vacío y solo espacios', () {
      expect(validarTitulo(''), isNotNull);
      expect(validarTitulo('   '), isNotNull);
      expect(validarTitulo(null), isNotNull);
    });

    test('rechaza títulos demasiado largos', () {
      expect(validarTitulo('a' * (maxLongitudTitulo + 1)), isNotNull);
    });

    test('acepta un título normal', () {
      expect(validarTitulo('Comprar leche'), isNull);
    });
  });

  group('TareasRepository', () {
    late Directory carpeta;
    late File archivo;

    setUp(() {
      carpeta = Directory.systemTemp.createTempSync('gestor_tareas_test');
      archivo = File('${carpeta.path}/tareas.sqlite');
    });

    tearDown(() => carpeta.deleteSync(recursive: true));

    test('no guarda un título vacío', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = TareasRepository(db);

      expect(() => repo.crear('   '), throwsArgumentError);
      expect(await repo.observarTareas().first, isEmpty);

      await db.close();
    });

    test('las tareas sobreviven a cerrar y reabrir la base (P1)', () async {
      var db = AppDatabase(NativeDatabase(archivo));
      var repo = TareasRepository(db);
      await repo.crear('Tarea 1');
      await repo.crear('  Tarea 2  ');
      await repo.crear('Tarea 3');
      await db.close(); // equivale a cerrar la app

      db = AppDatabase(NativeDatabase(archivo)); // "abrir" de nuevo
      repo = TareasRepository(db);
      final tareas = await repo.observarTareas().first;

      expect(tareas.map((t) => t.titulo), ['Tarea 1', 'Tarea 2', 'Tarea 3']);
      expect(tareas.every((t) => !t.completada), isTrue);
      expect(tareas.map((t) => t.id).toSet().length, 3); // ids únicos

      await db.close();
    });
  });
}
