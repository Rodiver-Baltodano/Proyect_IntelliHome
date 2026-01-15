import 'dart:io';
import 'dart:convert';
import 'models.dart';
import 'validador.dart';

// Gestor principal del módulo de registro
class RegistroManager {
  final String archivoJSON = 'usuarios_registro.json';

  // Cargar usuarios existentes del archivo JSON
  Future<List<Usuario>> cargarUsuarios() async {
    try {
      final archivo = File(archivoJSON);
      if (await archivo.exists()) {
        final contenido = await archivo.readAsString();
        // Validar que el contenido no esté vacío
        if (contenido.isEmpty) {
          return [];
        }
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
            'El username debe tener entre 3-20 caracteres (solo letras y números)',
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
          mensaje: 'Los datos de tarjeta deben ser solo letras y números',
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
