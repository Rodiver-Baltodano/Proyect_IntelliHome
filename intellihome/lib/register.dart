import 'dart:io';
import 'dart:convert';

// ==================== MODELOS ====================

class RegistroResult {
  final bool exito;
  final String? mensaje;

  RegistroResult({
    required this.exito,
    this.mensaje,
  });
}

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

// ==================== VALIDADORES ====================

class Validador {
  // Validar que sea alfanumérico (permite espacios, puntos, guiones)
  static bool esAlfanumerico(String valor) {
    final regex = RegExp(r'^[a-zA-Z0-9\s\.\-áéíóúñüÁÉÍÓÚÑÜ]+$');
    return regex.hasMatch(valor);
  }

  // Validar email con formato
  static bool esEmailValido(String email) {
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Validar teléfono (10-15 dígitos)
  static bool esTelefonoValido(String telefono) {
    final regex = RegExp(r'^[0-9\+\-\s]{10,15}$');
    return regex.hasMatch(telefono);
  }

  // Validar IBAN (formato básico)
  static bool esIBANValido(String iban) {
    final regex = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$');
    return regex.hasMatch(iban);
  }

  // Validar username (alfanumérico, guiones y guiones bajos, 3-20 caracteres)
  static bool esUsernameValido(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_-]{3,20}$');
    return regex.hasMatch(username);
  }

  // Validar contraseña (mínimo 8 caracteres)
  static bool esContrasenaValida(String contrasena) {
    return contrasena.length >= 8;
  }

  // Validar que nombre tenga al menos 2 palabras (nombre y apellido)
  static bool esNombreValido(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.length >= 2 && esAlfanumerico(nombre);
  }
}

// ==================== GESTOR DE REGISTRO ====================

class RegistroManager {
  final String archivoJSON = 'usuarios_registro.json';

  // Cargar usuarios existentes del archivo JSON
  Future<List<Usuario>> cargarUsuarios() async {
    try {
      final archivo = File(archivoJSON);
      if (await archivo.exists()) {
        final contenido = await archivo.readAsString();
        final List<dynamic> datos = jsonDecode(contenido);
        return datos.map((u) => Usuario.fromJson(u)).toList();
      }
      return [];
    } catch (e) {
      print('Error al cargar usuarios: $e');
      return [];
    }
  }

  // Guardar usuarios en el archivo JSON
  Future<bool> guardarUsuarios(List<Usuario> usuarios) async {
    try {
      final archivo = File(archivoJSON);
      final usuariosJson = usuarios.map((u) => u.toJson()).toList();
      await archivo.writeAsString(jsonEncode(usuariosJson), flush: true);
      return true;
    } catch (e) {
      print('Error al guardar usuarios: $e');
      return false;
    }
  }

  // Función auxiliar: verificar si el email ya existe
  Future<bool> emailYaExiste(String email, List<Usuario> usuarios) async {
    return usuarios.any((u) => u.email.toLowerCase() == email.toLowerCase());
  }

  // Función auxiliar: verificar si el username ya existe
  Future<bool> usernameYaExiste(String username, List<Usuario> usuarios) async {
    return usuarios.any((u) => u.username.toLowerCase() == username.toLowerCase());
  }

  // Función auxiliar: verificar si el teléfono ya existe
  Future<bool> telefonoYaExiste(String telefono, List<Usuario> usuarios) async {
    return usuarios.any((u) => u.telefono == telefono);
  }

  // Función principal de registro - Retorna RegistroResult con exito y mensaje de error
  Future<RegistroResult> registrarUsuario({
    required String nombreApellidos,
    required String username,
    required String fotoPerfil,
    required String email,
    required String telefono,
    required String nacionalidad,
    required String numeroIBAN,
    required bool aceptaTerminos,
    required String contrasena,
    String? datosTargeta,
    String? huellaBiometrica,
  }) async {
    // ============ VALIDACIONES ============

    // Validar que acepte los términos
    if (!aceptaTerminos) {
      return RegistroResult(
        exito: false,
        mensaje: 'Debe aceptar los términos y condiciones',
      );
    }

    // Validar nombre y apellidos
    if (nombreApellidos.trim().isEmpty) {
      return RegistroResult(
        exito: false,
        mensaje: 'El nombre y apellidos no pueden estar vacíos',
      );
    }
    if (!Validador.esNombreValido(nombreApellidos)) {
      return RegistroResult(
        exito: false,
        mensaje:
            'El nombre debe contener al menos nombre y apellido, y solo caracteres alfanuméricos',
      );
    }

    // Validar username
    if (username.trim().isEmpty) {
      return RegistroResult(
        exito: false,
        mensaje: 'El username no puede estar vacío',
      );
    }
    if (!Validador.esUsernameValido(username)) {
      return RegistroResult(
        exito: false,
        mensaje:
            'El username debe tener entre 3-20 caracteres (alfanuméricos, guiones y guiones bajos)',//CAMBIAR GUIONES BAJOS
      );
    }

    // Validar email
    if (email.trim().isEmpty) {
      return RegistroResult(
        exito: false,
        mensaje: 'El email no puede estar vacío',
      );
    }
    if (!Validador.esEmailValido(email)) {
      return RegistroResult(
        exito: false,
        mensaje: 'El email no tiene un formato válido',
      );
    }

    // Validar teléfono
    if (telefono.trim().isEmpty) {
      return RegistroResult(
        exito: false,
        mensaje: 'El teléfono no puede estar vacío',
      );
    }
    if (!Validador.esTelefonoValido(telefono)) {
      return RegistroResult(
        exito: false,
        mensaje: 'El teléfono debe tener entre 10-15 dígitos',
      );
    }

    // Validar nacionalidad
    if (nacionalidad.trim().isEmpty) {
      return RegistroResult(
        exito: false,
        mensaje: 'La nacionalidad no puede estar vacía',
      );
    }
    if (!Validador.esAlfanumerico(nacionalidad)) {
      return RegistroResult(
        exito: false,
        mensaje: 'La nacionalidad solo debe contener caracteres alfanuméricos',
      );
    }

    // Validar IBAN
    if (numeroIBAN.trim().isEmpty) {
      return RegistroResult(
        exito: false,
        mensaje: 'El número IBAN no puede estar vacío',
      );
    }
    if (!Validador.esIBANValido(numeroIBAN)) {
      return RegistroResult(
        exito: false,
        mensaje: 'El formato del IBAN no es válido',
      );
    }

    // Validar foto de perfil
    if (fotoPerfil.trim().isEmpty) {
      return RegistroResult(
        exito: false,
        mensaje: 'La foto de perfil no puede estar vacía',
      );
    }

    // Validar contraseña
    if (!Validador.esContrasenaValida(contrasena)) {
      return RegistroResult(
        exito: false,
        mensaje: 'La contraseña debe tener mínimo 8 caracteres',
      );
    }

    // Validar datos opcionales si se proporcionan
    if (datosTargeta != null && datosTargeta.isNotEmpty) {
      if (!Validador.esAlfanumerico(datosTargeta)) {
        return RegistroResult(
          exito: false,
          mensaje: 'Los datos de tarjeta deben ser alfanuméricos',
        );
      }
    }

    // ============ VERIFICAR DUPLICADOS EN ARCHIVO ============

    final usuariosExistentes = await cargarUsuarios();

    // Verificar username duplicado
    if (await usernameYaExiste(username, usuariosExistentes)) {
      return RegistroResult(
        exito: false,
        mensaje: 'El username "$username" ya está registrado',
      );
    }

    // Verificar email duplicado
    if (await emailYaExiste(email, usuariosExistentes)) {
      return RegistroResult(
        exito: false,
        mensaje: 'El email "$email" ya está registrado',
      );
    }

    // Verificar teléfono duplicado
    if (await telefonoYaExiste(telefono, usuariosExistentes)) {
      return RegistroResult(
        exito: false,
        mensaje: 'El teléfono "$telefono" ya está registrado',
      );
    }

    // ============ CREAR Y GUARDAR USUARIO ============

    final nuevoUsuario = Usuario(
      nombreApellidos: nombreApellidos,
      username: username,
      fotoPerfil: fotoPerfil,
      email: email,
      telefono: telefono,
      nacionalidad: nacionalidad,
      numeroIBAN: numeroIBAN,
      aceptaTerminos: aceptaTerminos,
      datosTargeta: datosTargeta,
      huellaBiometrica: huellaBiometrica,
      contrasena: contrasena,
      fechaRegistro: DateTime.now().toString(),
    );

    usuariosExistentes.add(nuevoUsuario);
    final guardado = await guardarUsuarios(usuariosExistentes);

    if (!guardado) {
      return RegistroResult(
        exito: false,
        mensaje: 'Error al guardar los datos del usuario',
      );
    }

    return RegistroResult(
      exito: true,
      mensaje: null,
    );
  }

  // Función para obtener todos los usuarios (útil para la GUI)
  Future<List<Usuario>> obtenerTodosLosUsuarios() async {
    return await cargarUsuarios();
  }

  // Función para buscar usuario por username
  Future<Usuario?> buscarUsuarioPorUsername(String username) async {
    final usuarios = await cargarUsuarios();
    try {
      return usuarios.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

// ==================== FUNCIÓN PRINCIPAL DE PRUEBA ====================

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║     PRUEBAS DEL MÓDULO DE REGISTRO DE USUARIOS            ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  final manager = RegistroManager();

  // ============ PRUEBA 1: Registro exitoso ============
  print('📝 PRUEBA 1: Registro exitoso');
  print('─' * 60);
  var resultado = await manager.registrarUsuario(
    nombreApellidos: 'Juan Carlos Pérez López',
    username: 'juancarlos_perez',
    fotoPerfil: '/assets/fotos/juan.jpg',
    email: 'juan.carlos@example.com',
    telefono: '+34612345678',
    nacionalidad: 'España',
    numeroIBAN: 'ES9121000418450200051332',
    aceptaTerminos: true,
    contrasena: 'MiPassword123!',
    datosTargeta: null,
    huellaBiometrica: null,
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    print('Mensaje: ${resultado.mensaje}');
  }
  print('');

  // ============ PRUEBA 2: Registro exitoso con datos opcionales ============
  print('📝 PRUEBA 2: Registro con datos de tarjeta');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'María García Sánchez',
    username: 'maria_garcia',
    fotoPerfil: '/assets/fotos/maria.jpg',
    email: 'maria.garcia@example.com',
    telefono: '+34687654321',
    nacionalidad: 'México',
    numeroIBAN: 'MX0910050000012345678900',
    aceptaTerminos: true,
    contrasena: 'SecurePass456!',
    datosTargeta: '4532123456789012',
    huellaBiometrica: null,
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    print('Mensaje: ${resultado.mensaje}');
  }
  print('');

  // ============ PRUEBA 3: Username duplicado ============
  print('📝 PRUEBA 3: Intento de registro con username duplicado');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Otro Usuario Más',
    username: 'juancarlos_perez', // Username ya existe
    fotoPerfil: '/assets/fotos/otro.jpg',
    email: 'otro@example.com',
    telefono: '+34698765432',
    nacionalidad: 'Colombia',
    numeroIBAN: 'CO9300760001000193830663',
    aceptaTerminos: true,
    contrasena: 'OtherPass789!',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ PRUEBA 4: Email duplicado ============
  print('📝 PRUEBA 4: Intento de registro con email duplicado');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Usuario Tercero',
    username: 'usuario_tercero',
    fotoPerfil: '/assets/fotos/tercero.jpg',
    email: 'juan.carlos@example.com', // Email ya existe
    telefono: '+34645678901',
    nacionalidad: 'Argentina',
    numeroIBAN: 'AR9001514017940030003439',
    aceptaTerminos: true,
    contrasena: 'NewPassword321!',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ PRUEBA 5: Contraseña muy corta ============
  print('📝 PRUEBA 5: Contraseña menor a 8 caracteres');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Pedro Rodríguez García',
    username: 'pedro_rodriguez',
    fotoPerfil: '/assets/fotos/pedro.jpg',
    email: 'pedro.rodriguez@example.com',
    telefono: '+34756890123',
    nacionalidad: 'Chile',
    numeroIBAN: 'CL9301234567890123456789',
    aceptaTerminos: true,
    contrasena: 'Short1', // Menos de 8 caracteres
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ PRUEBA 6: Email inválido ============
  print('📝 PRUEBA 6: Email con formato inválido');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Ana Martínez López',
    username: 'ana_martinez',
    fotoPerfil: '/assets/fotos/ana.jpg',
    email: 'email_invalido.com', // Falta @
    telefono: '+34834567890',
    nacionalidad: 'Perú',
    numeroIBAN: 'PE3950000000000000123456',
    aceptaTerminos: true,
    contrasena: 'ValidPass123!',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ PRUEBA 7: Teléfono inválido ============
  print('📝 PRUEBA 7: Teléfono con formato inválido');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Carlos Fernández Ruiz',
    username: 'carlos_fernandez',
    fotoPerfil: '/assets/fotos/carlos.jpg',
    email: 'carlos.fernandez@example.com',
    telefono: '12345', // Muy corto
    nacionalidad: 'Venezuela',
    numeroIBAN: 'VE00012345678901234567',
    aceptaTerminos: true,
    contrasena: 'AnotherPass456!',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ PRUEBA 8: Sin aceptar términos ============
  print('📝 PRUEBA 8: Registro sin aceptar términos');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Laura Jiménez Santos',
    username: 'laura_jimenez',
    fotoPerfil: '/assets/fotos/laura.jpg',
    email: 'laura.jimenez@example.com',
    telefono: '+34912345678',
    nacionalidad: 'Ecuador',
    numeroIBAN: 'EC9401234567890123456789',
    aceptaTerminos: false, // NO acepta términos
    contrasena: 'SafePassword789!',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ PRUEBA 9: Username inválido ============
  print('📝 PRUEBA 9: Username con caracteres inválidos');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Roberto Díaz Morales',
    username: 'user@invalid!', // Caracteres no permitidos
    fotoPerfil: '/assets/fotos/roberto.jpg',
    email: 'roberto.diaz@example.com',
    telefono: '+34923456789',
    nacionalidad: 'Paraguay',
    numeroIBAN: 'PY9902000500020628633013',
    aceptaTerminos: true,
    contrasena: 'RobertoPass123!',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ PRUEBA 10: IBAN inválido ============
  print('📝 PRUEBA 10: IBAN con formato inválido');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Sofía Mendoza Gutiérrez',
    username: 'sofia_mendoza',
    fotoPerfil: '/assets/fotos/sofia.jpg',
    email: 'sofia.mendoza@example.com',
    telefono: '+34934567890',
    nacionalidad: 'Bolivia',
    numeroIBAN: 'INVALID123', // IBAN inválido
    aceptaTerminos: true,
    contrasena: 'SofiaPass456!',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  print('Mensaje: ${resultado.mensaje}');
  print('');

  // ============ MOSTRAR TODOS LOS USUARIOS REGISTRADOS ============
  print('📋 USUARIOS REGISTRADOS EN EL SISTEMA');
  print('═' * 60);
  final todosLosUsuarios = await manager.obtenerTodosLosUsuarios();

  if (todosLosUsuarios.isEmpty) {
    print('No hay usuarios registrados');
  } else {
    for (int i = 0; i < todosLosUsuarios.length; i++) {
      final usuario = todosLosUsuarios[i];
      print('\nUsuario ${i + 1}:');
      print('  Nombre: ${usuario.nombreApellidos}');
      print('  Username: ${usuario.username}');
      print('  Email: ${usuario.email}');
      print('  Teléfono: ${usuario.telefono}');
      print('  Nacionalidad: ${usuario.nacionalidad}');
      print('  IBAN: ${usuario.numeroIBAN}');
      if (usuario.datosTargeta != null && usuario.datosTargeta!.isNotEmpty) {
        print('  Tarjeta: ${usuario.datosTargeta}');
      }
      print('  Fecha Registro: ${usuario.fechaRegistro}');
      print('  ' + '─' * 56);
    }
  }

  print('\n✓ Pruebas completadas');
}
