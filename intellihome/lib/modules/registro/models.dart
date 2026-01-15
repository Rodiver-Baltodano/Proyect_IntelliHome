// Modelo de respuesta para operaciones de registro
class RegistroResult {
  final bool exito;
  final Map<String, String> errores; // {campo: mensaje de error}

  RegistroResult({
    required this.exito,
    this.errores = const {},
  });

  // Constructor de conveniencia para éxito
  factory RegistroResult.success() {
    return RegistroResult(exito: true);
  }

  // Constructor de conveniencia para error
  factory RegistroResult.error(Map<String, String> errores) {
    return RegistroResult(exito: false, errores: errores);
  }
}

// Modelo de usuario con todos los datos
class Usuario {
  final String nombreApellidos;
  final String username;
  final String fotoPerfil;
  final String email;
  final String telefono;
  final String nacionalidad;
  final String numeroIBAN;
  final bool aceptaTerminos;
  final String? datosTargeta;
  final String? huellaBiometrica;
  final String contrasena;
  final String fechaRegistro;

  Usuario({
    required this.nombreApellidos,
    required this.username,
    required this.fotoPerfil,
    required this.email,
    required this.telefono,
    required this.nacionalidad,
    required this.numeroIBAN,
    required this.aceptaTerminos,
    this.datosTargeta,
    this.huellaBiometrica,
    required this.contrasena,
    required this.fechaRegistro,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombreApellidos': nombreApellidos,
      'username': username,
      'fotoPerfil': fotoPerfil,
      'email': email,
      'telefono': telefono,
      'nacionalidad': nacionalidad,
      'numeroIBAN': numeroIBAN,
      'aceptaTerminos': aceptaTerminos,
      'datosTargeta': datosTargeta,
      'huellaBiometrica': huellaBiometrica,
      'contrasena': contrasena,
      'fechaRegistro': fechaRegistro,
    };
  }

  // Crear desde JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombreApellidos: json['nombreApellidos'],
      username: json['username'],
      fotoPerfil: json['fotoPerfil'],
      email: json['email'],
      telefono: json['telefono'],
      nacionalidad: json['nacionalidad'],
      numeroIBAN: json['numeroIBAN'],
      aceptaTerminos: json['aceptaTerminos'],
      datosTargeta: json['datosTargeta'],
      huellaBiometrica: json['huellaBiometrica'],
      contrasena: json['contrasena'],
      fechaRegistro: json['fechaRegistro'],
    );
  }
}
