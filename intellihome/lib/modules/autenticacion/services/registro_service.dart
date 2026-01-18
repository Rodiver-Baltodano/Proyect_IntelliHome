import 'package:uuid/uuid.dart';
import 'package:intellihome/modules/autenticacion/models/resultado_registro.dart';
import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/autenticacion/validators/validators.dart';

/// Servicio unificado de registro de usuarios
/// Maneja la creación de nuevos usuarios con validación completa
class RegistroServicio {
  final UsuarioRepositorioJson _repositorio;

  RegistroServicio({required UsuarioRepositorioJson repositorio})
    : _repositorio = repositorio;

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
    required DateTime fechaNacimiento,
    String? huellaBiometrica,
    String? numeroTarjeta,
    String? fechaExpiracion,
    String? cvv,
  }) async {
    // Acumula errores de validación
    final errores = <String, String>{};

    // ========== VALIDACIONES ==========
    // Nombre y apellidos
    if (nombreApellidos.isEmpty) {
      errores['nombreApellidos'] = 'El nombre y apellidos son requeridos';
    } else if (!ValidacionesAutenticacion.esNombreValido(nombreApellidos)) {
      errores['nombreApellidos'] =
          'El nombre y apellidos son requeridos, sólo se permiten letras y espacios';
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
    if (numeroIBAN.isNotEmpty){
      if (!ValidacionesAutenticacion.esIBANValido(numeroIBAN)) {
      errores['numeroIBAN'] = 'El IBAN no tiene un formato válido';
    }
    } 

    // Fecha de nacimiento (mayoría de edad)
    if (!ValidacionesAutenticacion.esMayorDeEdad(fechaNacimiento)) {
      errores['fechaNacimiento'] = 'Debes ser mayor de 18 años';
    }

    // Tarjeta (opcional, pero si se completa alguno se validan todos)
    final tarjetaIngresada =
        (numeroTarjeta?.trim().isNotEmpty ?? false) ||
        (fechaExpiracion?.trim().isNotEmpty ?? false) ||
        (cvv?.trim().isNotEmpty ?? false);

    if (tarjetaIngresada) {
      final numTarjeta = numeroTarjeta?.replaceAll(RegExp(r'\s+'), '') ?? '';
      if (numTarjeta.isEmpty ||
          numTarjeta.length < 13 ||
          numTarjeta.length > 19 ||
          !RegExp(r'^\d{13,19}$').hasMatch(numTarjeta)) {
        errores['numeroTarjeta'] = 'Número de tarjeta inválido';
      }

      if (fechaExpiracion == null ||
          !RegExp(
            r'^(0[1-9]|1[0-2])\/\d{2}$',
          ).hasMatch(fechaExpiracion.trim())) {
        errores['fechaExpiracion'] = 'Fecha de expiración inválida (MM/AA)';
      } else {
        final partes = fechaExpiracion.split('/');
        final mes = int.tryParse(partes[0]);
        final anio = int.tryParse('20${partes[1]}');
        if (mes == null || anio == null) {
          errores['fechaExpiracion'] = 'Fecha de expiración inválida';
        } else {
          final ahora = DateTime.now();
          final finMes = DateTime(anio, mes + 1, 0);
          if (!finMes.isAfter(DateTime(ahora.year, ahora.month, 0))) {
            errores['fechaExpiracion'] = 'La tarjeta está expirada';
          }
        }
      }

      if (cvv == null || !RegExp(r'^\d{3,4}$').hasMatch(cvv.trim())) {
        errores['cvv'] = 'CVV inválido';
      }
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
      if (usuariosExistentes.any(
        (u) => u.username.toLowerCase() == username.toLowerCase(),
      )) {
        return ResultadoRegistro.error(
          'username',
          'El nombre de usuario ya está registrado',
        );
      }

      // Verificar correo duplicado
      if (usuariosExistentes.any(
        (u) => u.correo.toLowerCase() == correo.toLowerCase(),
      )) {
        return ResultadoRegistro.error(
          'correo',
          'El correo ya está registrado',
        );
      }

      // Verificar teléfono duplicado
      if (usuariosExistentes.any((u) => u.telefono == telefono)) {
        return ResultadoRegistro.error(
          'telefono',
          'El teléfono ya está registrado',
        );
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
        datosTargeta: _construirDatosTarjeta(numeroTarjeta, fechaExpiracion),
        huellaBiometrica: huellaBiometrica,
        fechaRegistro: DateTime.now(),
        fechaNacimiento: fechaNacimiento,
      );

      await _repositorio.guardarUsuario(nuevoUsuario);

      return ResultadoRegistro.exito(usuario: nuevoUsuario);
    } catch (e) {
      return ResultadoRegistro.fallo(
        'Error al registrar usuario: ${e.toString()}',
      );
    }
  }

  String? _construirDatosTarjeta(
    String? numeroTarjeta,
    String? fechaExpiracion,
  ) {
    if (numeroTarjeta == null || numeroTarjeta.trim().isEmpty) return null;
    final limpia = numeroTarjeta.replaceAll(RegExp(r'\s+'), '');
    final ultimos4 = limpia.length >= 4
        ? limpia.substring(limpia.length - 4)
        : limpia;
    final mascara = '**** **** **** $ultimos4';
    if (fechaExpiracion != null && fechaExpiracion.trim().isNotEmpty) {
      return '$mascara (exp $fechaExpiracion)';
    }
    return mascara;
  }
}
