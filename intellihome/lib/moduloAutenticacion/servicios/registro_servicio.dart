import 'package:uuid/uuid.dart';
import '../modelos/usuario.dart';
import '../modelos/resultado_registro.dart';
import '../validadores/validadores.dart';
import '../repositorios/usuario_repositorio_json.dart';

/// Servicio unificado de registro de usuarios
/// Maneja la creación de nuevos usuarios con validación completa
class RegistroServicio {
  final UsuarioRepositorioJson _repositorio;

  RegistroServicio({
    required UsuarioRepositorioJson repositorio,
  }) : _repositorio = repositorio;

  /// Registra un nuevo usuario con todos sus datos
  Future<ResultadoRegistro> registrarUsuario({
    required String nombreApellidos,
    required String username,
    required String correo,
    required String telefono,
    required String contrasena,
    required String nacionalidad,
    required String numeroIBAN,
    required String fotoPerfil,
    required bool aceptaTerminos,
    String? datosTargeta,
    String? huellaBiometrica,
  }) async {
    // Acumula errores de validación
    final errores = <String, String>{};

    // ========== VALIDACIONES ==========

    // Nombre y apellidos
    if (nombreApellidos.isEmpty) {
      errores['nombreApellidos'] = 'El nombre y apellidos son requeridos';
    } else if (!ValidacionesAutenticacion.esNombreValido(nombreApellidos)) {
      errores['nombreApellidos'] =
          'El nombre debe contener solo letras y espacios';
    }

    // Username
    if (username.isEmpty) {
      errores['username'] = 'El nombre de usuario es requerido';
    } else if (!ValidacionesAutenticacion.esUsernameValido(username)) {
      errores['username'] =
          'El username debe tener entre 3 y 20 caracteres alfanuméricos';
    }

    // Email
    if (correo.isEmpty) {
      errores['correo'] = 'El correo es requerido';
    } else if (!ValidacionesAutenticacion.esEmailValido(correo)) {
      errores['correo'] = 'El correo no tiene un formato válido';
    }

    // Teléfono
    if (telefono.isEmpty) {
      errores['telefono'] = 'El teléfono es requerido';
    } else if (!ValidacionesAutenticacion.esTelefonoValido(telefono)) {
      errores['telefono'] = 'El teléfono debe tener entre 8 y 15 dígitos';
    }

    // Contraseña
    if (contrasena.isEmpty) {
      errores['contrasena'] = 'La contraseña es requerida';
    } else if (!ValidacionesAutenticacion.esContrasenaValida(contrasena)) {
      errores['contrasena'] =
          'La contraseña debe tener mínimo 8 caracteres alfanuméricos';
    }

    // Nacionalidad
    if (nacionalidad.isEmpty) {
      errores['nacionalidad'] = 'La nacionalidad es requerida';
    }

    // Número IBAN
    if (numeroIBAN.isEmpty) {
      errores['numeroIBAN'] = 'El IBAN es requerido';
    } else if (!ValidacionesAutenticacion.esIBANValido(numeroIBAN)) {
      errores['numeroIBAN'] = 'El IBAN no tiene un formato válido';
    }

    // Foto de perfil
    if (fotoPerfil.isEmpty) {
      errores['fotoPerfil'] = 'La foto de perfil es requerida';
    }

    // Términos y condiciones
    if (!aceptaTerminos) {
      errores['aceptaTerminos'] = 'Debes aceptar los términos y condiciones';
    }

    // Si hay errores, retorna sin guardar
    if (errores.isNotEmpty) {
      return ResultadoRegistro.conErrores(errores);
    }

    // ========== VERIFICAR DUPLICADOS ==========

    try {
      final usuariosExistentes = await _repositorio.cargarUsuarios();

      // Verificar username duplicado
      if (usuariosExistentes
          .any((u) => u.username.toLowerCase() == username.toLowerCase())) {
        return ResultadoRegistro.error(
            'username', 'El nombre de usuario ya está registrado');
      }

      // Verificar correo duplicado
      if (usuariosExistentes
          .any((u) => u.correo.toLowerCase() == correo.toLowerCase())) {
        return ResultadoRegistro.error(
            'correo', 'El correo ya está registrado');
      }

      // Verificar teléfono duplicado
      if (usuariosExistentes.any((u) => u.telefono == telefono)) {
        return ResultadoRegistro.error(
            'telefono', 'El teléfono ya está registrado');
      }

      // ========== CREAR Y GUARDAR USUARIO ==========

      final nuevoUsuario = Usuario(
        id: const Uuid().v4(),
        username: username,
        nombreApellidos: nombreApellidos,
        correo: correo,
        telefono: telefono,
        contrasena: contrasena,
        nacionalidad: nacionalidad,
        numeroIBAN: numeroIBAN,
        fotoPerfil: fotoPerfil,
        aceptaTerminos: aceptaTerminos,
        datosTargeta: datosTargeta,
        huellaBiometrica: huellaBiometrica,
        fechaRegistro: DateTime.now(),
      );

      await _repositorio.guardarUsuario(nuevoUsuario);

      return ResultadoRegistro.exito(usuario: nuevoUsuario);
    } catch (e) {
      return ResultadoRegistro.fallo(
          'Error al registrar usuario: ${e.toString()}');
    }
  }
}
