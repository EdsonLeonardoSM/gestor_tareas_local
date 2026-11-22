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

Los datos son locales a cada instalación; en web quedan ligados al origen y perfil del navegador.
