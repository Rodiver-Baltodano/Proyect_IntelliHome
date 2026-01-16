import 'dart:convert';
import 'dart:io';

import 'package:intellihome/modules/autenticacion/models/usuario.dart';

/// Repositorio que carga y guarda usuarios en un archivo JSON.
///
/// Formatos soportados:
/// 1) Lista raíz:
///    [ {usuario1}, {usuario2} ]
///
/// 2) Objeto con clave "usuarios":
///    { "usuarios": [ {usuario1}, {usuario2} ] }
class UsuarioRepositorioJson {
  final String rutaArchivo;

  UsuarioRepositorioJson({required this.rutaArchivo});

  /// Lee el archivo JSON y devuelve la lista de usuarios.
  Future<List<Usuario>> cargarUsuarios() async {
    final archivo = File(rutaArchivo);

    print('📂 [REPO] Cargando usuarios desde: $rutaArchivo');

    if (!await archivo.exists()) {
      // Si no existe, devolvemos lista vacía (o podés lanzar error si preferís)
      print('⚠️ [REPO] Archivo no existe, retornando lista vacía.');
      return [];
    }

    final contenido = await archivo.readAsString();
    if (contenido.trim().isEmpty) {
      return [];
    }

    final dynamic data = jsonDecode(contenido);

    List<dynamic> listaJson;

    if (data is List) {
      listaJson = data;
    } else if (data is Map<String, dynamic> && data['usuarios'] is List) {
      listaJson = data['usuarios'] as List;
    } else {
      throw FormatException('Formato JSON de usuarios no soportado.');
    }

    return listaJson
        .whereType<Map<String, dynamic>>()
        .map((u) => Usuario.fromJson(u))
        .toList();
  }

  /// Guarda la lista completa de usuarios al archivo JSON.
  /// Por simplicidad, guarda como LISTA RAÍZ.
  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    final archivo = File(rutaArchivo);

    // Asegurar que la carpeta exista
    await archivo.parent.create(recursive: true);

    final lista = usuarios.map((u) => u.toJson()).toList();
    final contenido = const JsonEncoder.withIndent('  ').convert(lista);

    await archivo.writeAsString(contenido);
  }

  /// Busca por username/correo/teléfono (case-insensitive para username/correo).
  /// Teléfono se compara "normalizado" (solo dígitos; elimina +, espacios, guiones, etc.)
  Future<Usuario?> buscarPorIdentificador(String identificador) async {
    final usuarios = await cargarUsuarios();
    return _buscarEnLista(usuarios, identificador);
  }

  /// Igual que buscarPorIdentificador, pero usando una lista ya cargada (más eficiente).
  Usuario? buscarEnLista(List<Usuario> usuarios, String identificador) {
    return _buscarEnLista(usuarios, identificador);
  }

  /// Actualiza (reemplaza) un usuario por id y guarda.
  Future<void> actualizarUsuario(Usuario usuarioActualizado) async {
    final usuarios = await cargarUsuarios();

    final index = usuarios.indexWhere((u) => u.id == usuarioActualizado.id);
    if (index == -1) {
      // Si no existe, podés decidir lanzar error o agregarlo.
      throw StateError('No se encontró el usuario con id=${usuarioActualizado.id}');
    }

    usuarios[index] = usuarioActualizado;
    await guardarUsuarios(usuarios);
  }

  /// Guarda un nuevo usuario (lo agrega a la lista existente).
  Future<void> guardarUsuario(Usuario nuevoUsuario) async {
    final usuarios = await cargarUsuarios();

    // Verificar que no exista con el mismo id
    if (usuarios.any((u) => u.id == nuevoUsuario.id)) {
      throw StateError('Ya existe un usuario con id=${nuevoUsuario.id}');
    }

    usuarios.add(nuevoUsuario);
    await guardarUsuarios(usuarios);
  }

  /// Normaliza teléfono dejando solo dígitos.
  String _normalizarTelefono(String telefono) {
    return telefono.replaceAll(RegExp(r'\D'), '');
  }

  Usuario? _buscarEnLista(List<Usuario> usuarios, String identificador) {
    final idTrim = identificador.trim();
    if (idTrim.isEmpty) return null;

    final idLower = idTrim.toLowerCase();
    final idTelefono = _normalizarTelefono(idTrim);

    for (final u in usuarios) {
      final usernameLower = u.username.trim().toLowerCase();
      final correoLower = u.correo.trim().toLowerCase();
      final telefonoNorm = _normalizarTelefono(u.telefono);

      if (idLower == usernameLower) return u;
      if (idLower == correoLower) return u;

      // Si el usuario metió teléfono, comparamos normalizado
      if (idTelefono.isNotEmpty && idTelefono == telefonoNorm) return u;

      // También soporta +506XXXXXXXX / 506XXXXXXXX comparando últimos 8 dígitos
      if (idTelefono.length > 8 && telefonoNorm.length >= 8) {
        final ult8Input = idTelefono.substring(idTelefono.length - 8);
        final ult8User = telefonoNorm.substring(telefonoNorm.length - 8);
        if (ult8Input == ult8User) return u;
      }
    }

    return null;
  }
}
