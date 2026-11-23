# Gestor de tareas local (SQLite + Drift)

Práctica de Programación de Dispositivos Móviles (UAA, ISC, 7.º semestre): gestor de tareas con
persistencia local en SQLite, sin servidor, sin MySQL y sin conexión a internet. Un solo proyecto
Flutter pensado para Android, iOS, Windows, Linux, macOS y web.

## Tecnología de persistencia elegida: Drift + drift_flutter

| Paquete | Para qué se usa |
|---|---|
| `drift` | ORM reactivo sobre SQLite: tablas declaradas en Dart, consultas tipadas, `Stream` de resultados. |
| `drift_flutter` | Abre la base de forma correcta en cada plataforma con una sola llamada (`driftDatabase`): archivo nativo en móvil/escritorio, WebAssembly + almacenamiento del navegador en web. |
| `drift_dev` + `build_runner` (dev) | Generan en tiempo de compilación el código de la base (`*.g.dart`) a partir de las tablas declaradas. |

**Por qué Drift y no `sqflite` o `sqlite3` a mano:** `sqflite` no cubre web, Windows ni Linux sin
paquetes adicionales, lo que rompería el requisito de una sola base de código para las seis
plataformas. Drift con `drift_flutter` sí lo resuelve y además ofrece consultas reactivas, de modo
que la interfaz se actualiza sola tras cada escritura sin consultar manualmente. Se descartan
`shared_preferences` y las listas en memoria porque la consigna no los acepta como persistencia.

## Diseño de la tabla

Tabla `tareas`:

| Columna | Tipo Dart (Drift) | Tipo SQLite | Restricciones |
|---|---|---|---|
| `id` | `integer().autoIncrement()` | `INTEGER` | Clave primaria; identifica de forma única cada registro. |
| `titulo` | `text().withLength(min: 1, max: 100)` | `TEXT` | Obligatorio; se valida además en la interfaz (sin vacíos ni solo espacios). |
| `completada` | `boolean().withDefault(const Constant(false))` | `INTEGER` (0/1) | SQLite no tiene tipo booleano: se guarda como 0 o 1. |

Cada tarea se identifica por `id`, que genera SQLite y no cambia aunque se edite el título. Las
operaciones de edición, cambio de estado y eliminación usan ese `id` en la cláusula `WHERE`.

## Estructura prevista

```
lib/
  main.dart            arranque y tema
  models/tarea.dart    modelo de la interfaz
  data/                capa de persistencia (base Drift)
  screens/             pantallas
test/                  pruebas automatizadas
```

## Cómo ejecutar

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d linux     # o: flutter run -d chrome
```

El código generado (`lib/data/app_database.g.dart`) ya está en el repositorio. Si se cambia la
tabla, se regenera con:

```bash
dart run build_runner build
```

## Web

SQLite en el navegador necesita WebAssembly, por eso `web/` incluye:

- `sqlite3.wasm`: release `sqlite3-3.5.2` de https://github.com/simolus3/sqlite3.dart/releases
  (misma versión que el paquete `sqlite3` de `pubspec.lock`).
- `drift_worker.js`: tomado del paquete `drift` 2.35.4 (misma versión que `pubspec.lock`).

Si se actualiza Drift o sqlite3, hay que reemplazar estos archivos por los de la nueva versión.

## Pruebas automatizadas

`flutter test` ejecuta 9 pruebas:

- `validarTitulo`: rechaza vacío, solo espacios y títulos muy largos; acepta un título normal.
- Repositorio: no guarda ni edita con un título vacío; las tareas, el estado, la edición y la
  eliminación se conservan al cerrar y reabrir un archivo SQLite; desmarcar regresa a pendiente.
- Interfaz: la pantalla inicial se muestra sin errores.

## Plataformas verificadas

| Plataforma | Estado |
|---|---|
| Web (Chrome) | Verificada: `flutter build web` y pruebas P1–P6 en Chrome (sin interfaz gráfica). |
| Linux | La app compila y abre, crea el archivo `gestor_tareas.sqlite`; P1–P5 cubiertas por las pruebas automatizadas. |
| Android, iOS, Windows, macOS | Solo previstas (el código es el mismo, no se probaron). |

Resultado de las pruebas de la consigna en web:

| Prueba | Resultado |
|---|---|
| P1 Agregar 3 tareas y recargar | Permanecen |
| P2 Marcar completada y recargar | Se conserva el estado |
| P3 Cambiar el título y recargar | Aparece el nuevo título |
| P4 Eliminar y recargar | No reaparece |
| P5 Título vacío o solo espacios | No se registra; se muestra el error |
| P6 Recargar la página | Los datos permanecen |

Limitaciones: en web se probó recargar la página, no cerrar y abrir el navegador. En esa prueba
Drift usó `sharedIndexedDb` porque el servidor local no envía las cabeceras que habilitan
`SharedArrayBuffer`; funciona igual. El límite de 100 caracteres del título lo valida el código,
no la base de datos.

Los datos son locales a cada instalación; en web quedan ligados al origen y perfil del navegador.
