/// Resultado unificado para operaciones de registro
class ResultadoRegistro {
  final bool exito;

  /// Errores específicos por campo (cuando exito = false)
  final Map<String, String> errores;

  /// Usuario registrado exitosamente
  final dynamic usuario; // Tipo Usuario, pero evita importación circular

  /// Mensaje general (para casos especiales)
  final String? mensaje;

  ResultadoRegistro({
    required this.exito,
    this.errores = const {},
    this.usuario,
    this.mensaje,
  });

  /// Resultado exitoso con usuario registrado
  factory ResultadoRegistro.exito({required dynamic usuario}) {
    return ResultadoRegistro(
      exito: true,
      usuario: usuario,
    );
  }

  /// Resultado fallido con errores por campo
  factory ResultadoRegistro.conErrores(Map<String, String> errores) {
    return ResultadoRegistro(
      exito: false,
      errores: errores,
    );
  }

  /// Resultado fallido con un solo error
  factory ResultadoRegistro.error(String campo, String mensaje) {
    return ResultadoRegistro(
      exito: false,
      errores: {campo: mensaje},
    );
  }

  /// Resultado fallido con un mensaje general
  factory ResultadoRegistro.fallo(String mensaje) {
    return ResultadoRegistro(
      exito: false,
      mensaje: mensaje,
    );
  }

  /// Verifica si hay errores de validación
  bool tienErroresValidacion() => errores.isNotEmpty;

  /// Obtiene el primer error disponible
  String? obtenerPrimerError() {
    if (errores.isNotEmpty) {
      return errores.values.first;
    }
    return mensaje;
  }

  @override
  String toString() {
    if (exito) {
      return 'ResultadoRegistro.exito(usuario: $usuario)';
    }
    if (errores.isNotEmpty) {
      return 'ResultadoRegistro.conErrores($errores)';
    }
    return 'ResultadoRegistro.fallo($mensaje)';
  }
}
