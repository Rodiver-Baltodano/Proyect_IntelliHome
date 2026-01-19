import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intellihome/modules/autenticacion/models/resultado_registro.dart';
import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/autenticacion/validators/validators.dart';
import 'package:intellihome/l10n/app_localizations.dart';

/// Servicio unificado de registro de usuarios
/// Maneja la creación de nuevos usuarios con validación completa
class RegistroServicio {
  final UsuarioRepositorioJson _repositorio;
  final BuildContext _context;

  RegistroServicio({
    required UsuarioRepositorioJson repositorio,
    required BuildContext context,
  })  : _repositorio = repositorio,
        _context = context;

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
    String? cedula,
    String? huellaBiometrica,
    String? numeroTarjeta,
    String? fechaExpiracion,
    String? cvv,
  }) async {
    final loc = AppLocalizations.of(_context);
    final errores = <String, String>{};

    // ========== VALIDACIONES ==========
    // Nombre y apellidos
    if (nombreApellidos.isEmpty) {
      errores['nombreApellidos'] = loc.nameRequired;
    } else if (!ValidacionesAutenticacion.esNombreValido(nombreApellidos)) {
      errores['nombreApellidos'] = loc.nameInvalidFormat;
    }

    // Username
    if (username.isEmpty) {
      errores['username'] = loc.usernameRequired;
    } else if (!ValidacionesAutenticacion.esUsernameValido(username)) {
      errores['username'] = loc.usernameInvalidFormat;
    }

    // Email
    if (correo.isEmpty) {
      errores['correo'] = loc.emailRequired;
    } else if (!ValidacionesAutenticacion.esEmailValido(correo)) {
      errores['correo'] = loc.emailInvalidFormat;
    }

    // Teléfono
    if (telefono.isEmpty) {
      errores['telefono'] = loc.phoneRequired;
    } else if (!ValidacionesAutenticacion.esTelefonoValido(telefono)) {
      errores['telefono'] = loc.phoneInvalidFormat;
    }

    // Cédula (OBLIGATORIA)
    if (cedula == null || cedula.trim().isEmpty) {
      errores['cedula'] = loc.idRequired;
    } else if (!ValidacionesAutenticacion.esCedulaValida(cedula, nacionalidad: nacionalidad)) {
      if (nacionalidad == 'Costa Rica') {
        errores['cedula'] = loc.idInvalidFormatCR;
      } else {
        errores['cedula'] = loc.idInvalidFormatGeneric;
      }
    }

    // Contraseña
    if (contrasena.isEmpty) {
      errores['contrasena'] = loc.passwordRequired;
    } else if (!ValidacionesAutenticacion.esContrasenaValida(contrasena)) {
      errores['contrasena'] = loc.passwordInvalidFormat;
    }

    // Nacionalidad
    if (nacionalidad.isEmpty) {
      errores['nacionalidad'] = loc.nationalityRequired;
    }

    // Número IBAN
    if (numeroIBAN.isNotEmpty) {
      if (!ValidacionesAutenticacion.esIBANValido(numeroIBAN)) {
        errores['numeroIBAN'] = loc.ibanInvalidFormat;
      }
    }

    // Fecha de nacimiento (mayoría de edad)
    if (!ValidacionesAutenticacion.esMayorDeEdad(fechaNacimiento)) {
      errores['fechaNacimiento'] = loc.mustBeOver18;
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
        errores['numeroTarjeta'] = loc.cardNumberInvalid;
      }

      if (fechaExpiracion == null ||
          !RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(fechaExpiracion.trim())) {
        errores['fechaExpiracion'] = loc.cardExpiryInvalid;
      } else {
        final partes = fechaExpiracion.split('/');
        final mes = int.tryParse(partes[0]);
        final anio = int.tryParse('20${partes[1]}');
        if (mes == null || anio == null) {
          errores['fechaExpiracion'] = loc.cardExpiryInvalid;
        } else {
          final ahora = DateTime.now();
          final finMes = DateTime(anio, mes + 1, 0);
          if (!finMes.isAfter(DateTime(ahora.year, ahora.month, 0))) {
            errores['fechaExpiracion'] = loc.cardExpired;
          }
        }
      }

      if (cvv == null || !RegExp(r'^\d{3,4}$').hasMatch(cvv.trim())) {
        errores['cvv'] = loc.cvvInvalid;
      }
    }

    // Términos y condiciones
    if (!aceptaTerminos) {
      errores['aceptaTerminos'] = loc.mustAcceptTermsValidation;
    }

    // Foto de perfil (OBLIGATORIA)
    if (fotoPerfil.isEmpty || fotoPerfil.contains('placeholder')) {
      errores['fotoPerfil'] = loc.profilePhotoRequired;
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
          loc.usernameAlreadyExists,
        );
      }

      // Verificar correo duplicado
      if (usuariosExistentes.any(
        (u) => u.correo.toLowerCase() == correo.toLowerCase(),
      )) {
        return ResultadoRegistro.error(
          'correo',
          loc.emailAlreadyExists,
        );
      }

      // Verificar teléfono duplicado
      if (usuariosExistentes.any((u) => u.telefono == telefono)) {
        return ResultadoRegistro.error(
          'telefono',
          loc.phoneAlreadyExists,
        );
      }

      // Verificar cédula duplicada
      if (cedula != null && cedula.isNotEmpty) {
        final cedulaLimpia = cedula.trim().replaceAll(RegExp(r'[\s\-]'), '');
        if (usuariosExistentes.any((u) =>
            u.cedula?.replaceAll(RegExp(r'[\s\-]'), '') == cedulaLimpia)) {
          return ResultadoRegistro.error(
            'cedula',
            loc.idAlreadyExists,
          );
        }
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
        cedula: cedula?.trim(),
        datosTargeta: _construirDatosTarjeta(numeroTarjeta, fechaExpiracion),
        huellaBiometrica: huellaBiometrica,
        fechaRegistro: DateTime.now(),
        fechaNacimiento: fechaNacimiento,
      );

      await _repositorio.guardarUsuario(nuevoUsuario);

      return ResultadoRegistro.exito(usuario: nuevoUsuario);
    } catch (e) {
      return ResultadoRegistro.fallo(
        '${loc.registrationError}: ${e.toString()}',
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