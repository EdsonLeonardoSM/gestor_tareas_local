import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:gestor_tareas_local/data/tareas_repository.dart';
import 'package:gestor_tareas_local/main.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(GestorTareasApp(repositorio: TareasRepository(db)));
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Se desmonta la pantalla (cancela el stream) y se deja correr el
    // temporizador de Drift; la base se cierra fuera del reloj simulado.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });
}
