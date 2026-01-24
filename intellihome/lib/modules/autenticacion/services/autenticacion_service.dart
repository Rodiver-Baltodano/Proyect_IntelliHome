import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intellihome/modules/autenticacion/models/resultado_autenticacion.dart';
import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/autenticacion/validators/validators.dart';
import 'package:intellihome/modules/autenticacion/services/email_service.dart';
import 'package:intellihome/l10n/app_localizations.dart';

/// Servicio principal de autenticación
class AutenticacionServicio {
  final UsuarioRepositorioJson usuarioRepositorio;
  final BuildContext _context;
  final int maxIntentos;
  final Duration duracionCodigoRecuperacion;

  AutenticacionServicio({
    required this.usuarioRepositorio,
    required BuildContext context,
    this.maxIntentos = 5,
    this.duracionCodigoRecuperacion = const Duration(minutes: 10),
  }) : _context = context;

  // =========================
  // LOGIN
  // =========================

  Future<ResultadoAutenticacion> iniciarSesion({
    required String identificador,
    required String contrasena,
  }) async {
    final loc = AppLocalizations.of(_context);
    final id = identificador.trim();
    final pass = contrasena.trim();

    // 1) Validar formato
    final formatoIdentificadorValido = _identificadorEsValido(id);
    final formatoContrasenaValido = ValidacionesAutenticacion.esContrasenaValida(pass);

    if (!formatoIdentificadorValido || !formatoContrasenaValido) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: loc.invalidIdentifierAndPassword,
      );
    }

    // 2) Buscar usuario
    final Usuario? usuario = await usuarioRepositorio.buscarPorIdentificador(id);

    if (usuario == null) {
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: loc.verifyDataOrRegister,
      );
    }

    // 3) Verificar bloqueo
    if (usuario.estaBloqueado || usuario.intentosFallidos >= maxIntentos) {
      usuario.estaBloqueado = true;
      await usuarioRepositorio.actualizarUsuario(usuario);

      return ResultadoAutenticacion.usuarioBloqueado(
        mensaje: loc.userBlockedUseRecovery,
      );
    }

    // 4) Comparar credenciales
    if (usuario.contrasena != pass) {
      usuario.incrementarIntentosFallidos(maxIntentos: maxIntentos);
      await usuarioRepositorio.actualizarUsuario(usuario);

      if (usuario.estaBloqueado || usuario.intentosFallidos >= maxIntentos) {
        return ResultadoAutenticacion.usuarioBloqueado(
          mensaje: loc.userBlockedUseRecovery,
        );
      }

      final restantes = max(0, maxIntentos - usuario.intentosFallidos);
      return ResultadoAutenticacion.credencialesInvalidas(
        mensaje: '${loc.incorrectPassword}. ${loc.attemptsRemaining}: $restantes.',
        intentosRestantes: restantes,
      );
    }

    // 5) Éxito
    usuario.reiniciarIntentos();
    await usuarioRepositorio.actualizarUsuario(usuario);

    return ResultadoAutenticacion.exitoso(
      mensaje: loc.loginSuccessMessage,
      idUsuario: usuario.id,
      username: usuario.username,
    );
  }

  bool _identificadorEsValido(String identificador) {
    return ValidacionesAutenticacion.esEmailValido(identificador) ||
        ValidacionesAutenticacion.esTelefonoValido(identificador) ||
        ValidacionesAutenticacion.esUsernameValido(identificador);
  }

  // =========================
  // OLVIDÉ LA CONTRASEÑA
  // =========================

  Future<ResultadoAutenticacion> solicitarCodigoRecuperacion({
    required String identificador,
    bool mostrarCodigoParaPruebas = true,
  }) async {
    final loc = AppLocalizations.of(_context);
    final id = identificador.trim();

    if (id.isEmpty) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: loc.enterPhoneEmailOrUser,
      );
    }

    if (!_identificadorEsValido(id)) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: loc.invalidIdentifierFormat,
      );
    }

    final usuario = await usuarioRepositorio.buscarPorIdentificador(id);
    if (usuario == null) {
      print('❌ [RECUPERACIÓN] Usuario no encontrado: $id');
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: loc.userNotFoundRecovery,
      );
    }

    print('✓ [RECUPERACIÓN] Usuario encontrado: $id (ID: ${usuario.id})');

    final codigo = _generarCodigo6Digitos();
    print('🔑 [RECUPERACIÓN] Código de recuperación para $id: $codigo');

    usuario.asignarCodigoRecuperacion(codigo, duracionCodigoRecuperacion);
    usuario.intentosFallidosCodigo = 0;
    print('🔄 [RECUPERACIÓN] Intentos de código reseteados a 0 para nueva sesión de recuperación.');

    await usuarioRepositorio.actualizarUsuario(usuario);

    final emailEnviado = await EmailService.enviarCodigoRecuperacion(
      email: usuario.correo,
      codigo: codigo,
      nombreUsuario: usuario.username,
    );

    final mensajeBase = emailEnviado
        ? loc.recoveryCodeSentToEmail
        : '${loc.recoveryCodeGenerated}. (${loc.checkEnvConfiguration})';

    return ResultadoAutenticacion.exitoso(
      mensaje: mensajeBase,
      idUsuario: usuario.id,
      username: usuario.username,
    );
  }

  Future<ResultadoAutenticacion> verificarCodigoRecuperacion({
    required String identificador,
    required String codigo,
  }) async {
    final loc = AppLocalizations.of(_context);
    final id = identificador.trim();
    final cod = codigo.trim();

    if (!_identificadorEsValido(id) || cod.isEmpty) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: loc.invalidDataVerifyIdentifierAndCode,
      );
    }

    final usuario = await usuarioRepositorio.buscarPorIdentificador(id);
    if (usuario == null) {
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: loc.userNotFoundRecovery,
      );
    }

    final esValido = usuario.codigoRecuperacionEsValido(cod);
    print('📋 [VERIFICACIÓN CÓDIGO] Verificando código para $id. Intento ${usuario.intentosFallidosCodigo + 1} de $maxIntentos');

    if (!esValido) {
      print('❌ [VERIFICACIÓN CÓDIGO] Código inválido. Código actual en BD: ${usuario.codigoRecuperacion}, Enviado: $cod');

      usuario.incrementarIntentosFallidosCodigo(maxIntentos: maxIntentos);
      print('⚠️ [VERIFICACIÓN CÓDIGO] Intentos fallidos incrementados a: ${usuario.intentosFallidosCodigo}. Bloqueado: ${usuario.estaBloqueado}');

      await usuarioRepositorio.actualizarUsuario(usuario);

      if (usuario.estaBloqueado) {
        print('🔒 [VERIFICACIÓN CÓDIGO] Cuenta bloqueada por demasiados intentos fallidos.');
        return ResultadoAutenticacion.usuarioBloqueado(
          mensaje: '${loc.tooManyAttempts}. ${loc.accountBlockedContactSupport}',
        );
      }

      final restantes = maxIntentos - usuario.intentosFallidosCodigo;
      return ResultadoAutenticacion.credencialesInvalidas(
        mensaje: '${loc.invalidOrExpiredCode}. ${loc.attemptsRemaining}: $restantes. ${loc.requestNewCode}.',
        intentosRestantes: restantes,
      );
    }

    print('✅ [VERIFICACIÓN CÓDIGO] Código válido para $id');
    return ResultadoAutenticacion.exitoso(
      mensaje: loc.codeVerifiedCanUpdatePassword,
      idUsuario: usuario.id,
      username: usuario.username,
    );
  }

  Future<ResultadoAutenticacion> actualizarContrasenaConCodigo({
    required String identificador,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    final loc = AppLocalizations.of(_context);
    final id = identificador.trim();
    final cod = codigo.trim();
    final nueva = nuevaContrasena.trim();

    if (!_identificadorEsValido(id)) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: loc.invalidIdentifier,
      );
    }
    if (cod.isEmpty) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: loc.mustEnterCode,
      );
    }
    if (!ValidacionesAutenticacion.esContrasenaValida(nueva)) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: loc.passwordMustBeAlphanumeric8,
      );
    }

    final usuario = await usuarioRepositorio.buscarPorIdentificador(id);
    if (usuario == null) {
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: loc.userNotFoundRecovery,
      );
    }

    final esValido = usuario.codigoRecuperacionEsValido(cod);
    if (!esValido) {
      return ResultadoAutenticacion.credencialesInvalidas(
        mensaje: '${loc.invalidOrExpiredCodeRetry}.',
      );
    }

    usuario.contrasena = nueva;
    usuario.reiniciarIntentos();
    usuario.limpiarCodigoRecuperacion();

    await usuarioRepositorio.actualizarUsuario(usuario);

    return ResultadoAutenticacion.exitoso(
      mensaje: loc.passwordUpdatedCanLogin,
      idUsuario: usuario.id,
      username: usuario.username,
    );
  }

  String _generarCodigo6Digitos() {
    final random = Random.secure();
    final numero = random.nextInt(900000) + 100000;
    return numero.toString();
  }
}