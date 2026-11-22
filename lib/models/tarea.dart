const int maxLongitudTitulo = 100;

// Devuelve el mensaje de error, o null si el título es válido.
String? validarTitulo(String? titulo) {
  final limpio = titulo?.trim() ?? '';
  if (limpio.isEmpty) return 'El título no puede estar vacío';
  if (limpio.length > maxLongitudTitulo) {
    return 'El título no puede superar $maxLongitudTitulo caracteres';
  }
  return null;
}

class Tarea {
  final int id;
  final String titulo;
  final bool completada;

  const Tarea({
    required this.id,
    required this.titulo,
    required this.completada,
  });
}
