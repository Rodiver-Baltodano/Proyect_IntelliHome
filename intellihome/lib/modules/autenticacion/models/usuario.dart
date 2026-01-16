class Usuario {
  // ========== DEL LOGIN (Autenticación) ==========
  final String id;
  final String username;
  final String correo;
  final String telefono;

  /// Contraseña alfanumérica (idealmente hasheada en el futuro)
  String contrasena;

  /// Intentos fallidos de inicio de sesión
  int intentosFallidos;

  /// Indica si el usuario está bloqueado
  bool estaBloqueado;

  /// Código temporal para recuperación de contraseña
  String? codigoRecuperacion;

  /// Fecha de expiración del código de recuperación
  DateTime? codigoExpira;

  // ========== DEL REGISTRO (Datos adicionales) ==========
  final String nombreApellidos;
  final String nacionalidad;
  final String numeroIBAN;
  final String fotoPerfil;
  bool aceptaTerminos;
  final String? datosTargeta;        // Opcional
  final String? huellaBiometrica;    // Opcional
  final DateTime fechaRegistro;

  Usuario({
    required this.id,
    required this.username,
    required this.nombreApellidos,
    required this.correo,
    required this.telefono,
    required this.contrasena,
    required this.nacionalidad,
    required this.numeroIBAN,
    required this.fotoPerfil,
    required this.aceptaTerminos,
    this.datosTargeta,
    this.huellaBiometrica,
    this.intentosFallidos = 0,
    this.estaBloqueado = false,
    this.codigoRecuperacion,
    this.codigoExpira,
    required this.fechaRegistro,
  });

  /// Crea un Usuario a partir de un Map (JSON)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      username: json['username'] as String,
      nombreApellidos: json['nombreApellidos'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String,
      contrasena: json['contrasena'] as String,
      nacionalidad: json['nacionalidad'] as String,
      numeroIBAN: json['numeroIBAN'] as String,
      fotoPerfil: json['fotoPerfil'] as String,
      aceptaTerminos: json['aceptaTerminos'] as bool,
      datosTargeta: json['datosTargeta'],
      huellaBiometrica: json['huellaBiometrica'],
      intentosFallidos: json['intentosFallidos'] ?? 0,
      estaBloqueado: json['estaBloqueado'] ?? false,
      codigoRecuperacion: json['codigoRecuperacion'],
      codigoExpira: json['codigoExpira'] != null
          ? DateTime.parse(json['codigoExpira'])
          : null,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
    );
  }

  /// Convierte el Usuario a Map (para guardarlo en JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nombreApellidos': nombreApellidos,
      'correo': correo,
      'telefono': telefono,
      'contrasena': contrasena,
      'nacionalidad': nacionalidad,
      'numeroIBAN': numeroIBAN,
      'fotoPerfil': fotoPerfil,
      'aceptaTerminos': aceptaTerminos,
      'datosTargeta': datosTargeta,
      'huellaBiometrica': huellaBiometrica,
      'intentosFallidos': intentosFallidos,
      'estaBloqueado': estaBloqueado,
      'codigoRecuperacion': codigoRecuperacion,
      'codigoExpira': codigoExpira?.toIso8601String(),
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  /// Reinicia los intentos fallidos (cuando el login es exitoso)
  void reiniciarIntentos() {
    intentosFallidos = 0;
    estaBloqueado = false;
  }

  /// Incrementa intentos fallidos y bloquea si llega al máximo
  void incrementarIntentosFallidos({int maxIntentos = 5}) {
    intentosFallidos++;
    if (intentosFallidos >= maxIntentos) {
      estaBloqueado = true;
    }
  }

  /// Asigna un código de recuperación con expiración
  void asignarCodigoRecuperacion(String codigo, Duration duracion) {
    codigoRecuperacion = codigo;
    codigoExpira = DateTime.now().add(duracion);
  }

  /// Limpia el código de recuperación (cuando ya se usó)
  void limpiarCodigoRecuperacion() {
    codigoRecuperacion = null;
    codigoExpira = null;
  }

  /// Verifica si el código de recuperación es válido
  bool codigoRecuperacionEsValido(String codigo) {
    if (codigoRecuperacion == null || codigoExpira == null) {
      return false;
    }
    if (DateTime.now().isAfter(codigoExpira!)) {
      return false;
    }
    return codigoRecuperacion == codigo;
  }
}
