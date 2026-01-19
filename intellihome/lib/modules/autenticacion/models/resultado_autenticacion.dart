/// Resultado estandarizado del proceso de autenticación (Login).
/// Sirve para que la GUI pueda decidir:
/// - navegar si exito == true
/// - mostrar mensaje si exito == false
///
/// Incluye estados alineados al diagrama:
/// - exito
/// - errorCredencialesInvalidas
/// - errorFormatoInvalido
///
/// Y a tus requerimientos:
/// - usuarioNoExiste
/// - usuarioBloqueado (por 5 intentos)
/// - intentosRestantes
class ResultadoAutenticacion {
  final bool exito;

  // Alineado al diagrama
  final bool errorCredencialesInvalidas;
  final bool errorFormatoInvalido;

  // Requerimientos del proyecto
  final bool usuarioNoExiste;
  final bool usuarioBloqueado;

  /// Errores específicos por campo (para validaciones)
  final Map<String, String> errores;

  /// Intentos restantes antes de bloquear (si aplica).
  /// Ej: si ya falló 3 veces, y el máximo es 5 -> restantes = 2.
  final int? intentosRestantes;

  /// Mensaje listo para mostrar en UI.
  /// La GUI puede mostrar esto directamente.
  final String mensaje;

  /// Identificador del usuario autenticado (opcional).
  /// Puede ser username, id, o lo que definan en el JSON.
  final String? idUsuario;

  /// Username del usuario autenticado (opcional, útil para UI).
  final String? username;

  const ResultadoAutenticacion({
    required this.exito,
    required this.errorCredencialesInvalidas,
    required this.errorFormatoInvalido,
    required this.usuarioNoExiste,
    required this.usuarioBloqueado,
    required this.mensaje,
    this.errores = const {},
    this.intentosRestantes,
    this.idUsuario,
    this.username,
  });

  /// Factory para éxito.
  factory ResultadoAutenticacion.exitoso({
    String mensaje = 'Inicio de sesión exitoso.',
    String? idUsuario,
    String? username,
  }) {
    return ResultadoAutenticacion(
      exito: true,
      errorCredencialesInvalidas: false,
      errorFormatoInvalido: false,
      usuarioNoExiste: false,
      usuarioBloqueado: false,
      intentosRestantes: null,
      mensaje: mensaje,
      idUsuario: idUsuario,
      username: username,
    );
  }

  factory ResultadoAutenticacion.usuarioNoExiste({
    required String mensaje,
  }) {
    return ResultadoAutenticacion(
      exito: false,
      errorCredencialesInvalidas: true,
      errorFormatoInvalido: false,
      usuarioNoExiste: true,
      usuarioBloqueado: false,
      intentosRestantes: null,
      mensaje: mensaje,
    );
  }

  /// Factory para error de formato (email/teléfono/usuario o contraseña inválidos).
  factory ResultadoAutenticacion.errorFormato({
    required String mensaje,
  }) {
    return ResultadoAutenticacion(
      exito: false,
      errorCredencialesInvalidas: false,
      errorFormatoInvalido: true,
      usuarioNoExiste: false,
      usuarioBloqueado: false,
      intentosRestantes: null,
      mensaje: mensaje,
    );
  }

  /// Factory para usuario no existe.
 

  /// Factory para credenciales inválidas (usuario existe pero contraseña no coincide).
  factory ResultadoAutenticacion.credencialesInvalidas({
    required String mensaje,
    int? intentosRestantes,
  }) {
    return ResultadoAutenticacion(
      exito: false,
      errorCredencialesInvalidas: true,
      errorFormatoInvalido: false,
      usuarioNoExiste: false,
      usuarioBloqueado: false,
      intentosRestantes: intentosRestantes,
      mensaje: mensaje,
    );
  }

  /// Factory para usuario bloqueado (por intentos fallidos).
  factory ResultadoAutenticacion.usuarioBloqueado({
    required String mensaje,
  }) {
    return ResultadoAutenticacion(
      exito: false,
      errorCredencialesInvalidas: true,
      errorFormatoInvalido: false,
      usuarioNoExiste: false,
      usuarioBloqueado: true,
      intentosRestantes: 0,
      mensaje: mensaje,
    );
  }

  @override
  String toString() {
    return 'ResultadoAutenticacion('
        'exito: $exito, '
        'errorCredencialesInvalidas: $errorCredencialesInvalidas, '
        'errorFormatoInvalido: $errorFormatoInvalido, '
        'usuarioNoExiste: $usuarioNoExiste, '
        'usuarioBloqueado: $usuarioBloqueado, '
        'intentosRestantes: $intentosRestantes, '
        'mensaje: $mensaje, '
        'idUsuario: $idUsuario, '
        'username: $username'
        ')';
  }
}
