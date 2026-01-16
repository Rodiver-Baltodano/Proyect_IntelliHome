import 'dart:math';

import '../modelos/resultado_autenticacion.dart';
import '../modelos/usuario.dart';
import '../repositorios/usuario_repositorio_json.dart';
import '../validadores/validadores.dart';

/// Servicio principal de autenticación.
/// - Login con username/correo/teléfono
/// - Contraseña alfanumérica mínimo 8
/// - Bloqueo tras 5 intentos fallidos
/// - Recuperación: generar/verificar código y actualizar contraseña (desbloquea)
class AutenticacionServicio {
  final UsuarioRepositorioJson usuarioRepositorio;

  /// Máximo de intentos antes de bloquear.
  final int maxIntentos;

  /// Duración de validez del código de recuperación.
  final Duration duracionCodigoRecuperacion;

  AutenticacionServicio({
    required this.usuarioRepositorio,
    this.maxIntentos = 5,
    this.duracionCodigoRecuperacion = const Duration(minutes: 10),
  });

  // =========================
  // LOGIN
  // =========================

  Future<ResultadoAutenticacion> iniciarSesion({
    required String identificador,
    required String contrasena,
  }) async {
    final id = identificador.trim();
    final pass = contrasena.trim();

    // 1) Validar formato
    final formatoIdentificadorValido = _identificadorEsValido(id);
    final formatoContrasenaValido = ValidacionesAutenticacion.esContrasenaValida(pass);

    if (!formatoIdentificadorValido || !formatoContrasenaValido) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: 'Formato inválido. Verifique identificador y contraseña.',
      );
    }

    // 2) Buscar usuario
    final Usuario? usuario = await usuarioRepositorio.buscarPorIdentificador(id);

    if (usuario == null) {
      // Requisito: indicar que el usuario no existe
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: 'El usuario no existe. Verifique sus datos o regístrese.',
      );
    }

    // 3) Verificar bloqueo
    if (usuario.estaBloqueado || usuario.intentosFallidos >= maxIntentos) {
      // Asegurar consistencia
      usuario.estaBloqueado = true;
      await usuarioRepositorio.actualizarUsuario(usuario);

      return ResultadoAutenticacion.usuarioBloqueado(
        mensaje:
            'Usuario bloqueado por demasiados intentos. Use "Olvidé la contraseña" para desbloquear.',
      );
    }

    // 4) Comparar credenciales (contraseña)
    if (usuario.contrasena != pass) {
      usuario.incrementarIntentosFallidos(maxIntentos: maxIntentos);

      // Guardar cambios en JSON
      await usuarioRepositorio.actualizarUsuario(usuario);

      if (usuario.estaBloqueado || usuario.intentosFallidos >= maxIntentos) {
        return ResultadoAutenticacion.usuarioBloqueado(
          mensaje:
              'Usuario bloqueado por demasiados intentos. Use "Olvidé la contraseña" para desbloquear.',
        );
      }

      final restantes = max(0, maxIntentos - usuario.intentosFallidos);
      return ResultadoAutenticacion.credencialesInvalidas(
        mensaje: 'Contraseña incorrecta. Intentos restantes: $restantes.',
        intentosRestantes: restantes,
      );
    }

    // 5) Éxito: reiniciar intentos y desbloquear si aplica
    usuario.reiniciarIntentos();
    await usuarioRepositorio.actualizarUsuario(usuario);

    return ResultadoAutenticacion.exitoso(
      mensaje: 'Inicio de sesión exitoso.',
      idUsuario: usuario.id,
      username: usuario.username,
    );
  }

  bool _identificadorEsValido(String identificador) {
    // Se permite iniciar con username, correo o teléfono
    return ValidacionesAutenticacion.esEmailValido(identificador) ||
        ValidacionesAutenticacion.esTelefonoValido(identificador) ||
        ValidacionesAutenticacion.esUsernameValido(identificador);
  }

  // =========================
  // OLVIDÉ LA CONTRASEÑA
  // =========================

  /// Solicita un código de recuperación para el usuario identificado.
  /// Requisito: se "envía" al teléfono registrado.
  ///
  /// Importante:
  /// - Aquí SOLO generamos y guardamos el código + expiración.
  /// - La parte de "enviar SMS" real la implementan después.
  /// - Para pruebas, devolvemos el código en el mensaje (opcional).
  Future<ResultadoAutenticacion> solicitarCodigoRecuperacion({
    required String identificador,
    bool mostrarCodigoParaPruebas = true,
  }) async {
    final id = identificador.trim();

    if (!_identificadorEsValido(id)) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: 'Formato inválido. Ingrese usuario/correo/teléfono válido.',
      );
    }

    final usuario = await usuarioRepositorio.buscarPorIdentificador(id);
    if (usuario == null) {
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: 'El usuario no existe. Verifique sus datos.',
      );
    }

    // Generar código (6 dígitos)
    final codigo = _generarCodigo6Digitos();

    // Guardar código + expiración en usuario
    usuario.asignarCodigoRecuperacion(codigo, duracionCodigoRecuperacion);

    // Nota: No importa si estaba bloqueado: este flujo permite desbloquear.
    await usuarioRepositorio.actualizarUsuario(usuario);

    // Aquí es donde en el futuro se integra SMS real:
    // smsServicio.enviar(usuario.telefono, "Tu código es: $codigo");

    final mensajeBase =
        'Código de recuperación generado y enviado al teléfono registrado.';
    final mensaje = mostrarCodigoParaPruebas
        ? '$mensajeBase (PRUEBAS: código=$codigo)'
        : mensajeBase;

    return ResultadoAutenticacion.exitoso(mensaje: mensaje, idUsuario: usuario.id, username: usuario.username);
  }

  /// Verifica el código ingresado por el usuario.
  /// Si es válido, permite continuar al cambio de contraseña.
  Future<ResultadoAutenticacion> verificarCodigoRecuperacion({
    required String identificador,
    required String codigo,
  }) async {
    final id = identificador.trim();
    final cod = codigo.trim();

    if (!_identificadorEsValido(id) || cod.isEmpty) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: 'Datos inválidos. Verifique identificador y código.',
      );
    }

    final usuario = await usuarioRepositorio.buscarPorIdentificador(id);
    if (usuario == null) {
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: 'El usuario no existe. Verifique sus datos.',
      );
    }

    final esValido = usuario.codigoRecuperacionEsValido(cod);
    if (!esValido) {
      return ResultadoAutenticacion.credencialesInvalidas(
        mensaje: 'Código inválido o expirado. Solicite uno nuevo.',
      );
    }

    return ResultadoAutenticacion.exitoso(
      mensaje: 'Código verificado. Puede actualizar la contraseña.',
      idUsuario: usuario.id,
      username: usuario.username,
    );
  }

  /// Actualiza la contraseña usando el código.
  /// Requisitos:
  /// - La contraseña puede reutilizarse (no se valida contra histórico).
  /// - Debe ser alfanumérica y mínimo 8.
  /// - Debe desbloquear el usuario y reiniciar intentos.
  Future<ResultadoAutenticacion> actualizarContrasenaConCodigo({
    required String identificador,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    final id = identificador.trim();
    final cod = codigo.trim();
    final nueva = nuevaContrasena.trim();

    if (!_identificadorEsValido(id)) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: 'Identificador inválido.',
      );
    }
    if (cod.isEmpty) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: 'Debe ingresar el código.',
      );
    }
    if (!ValidacionesAutenticacion.esContrasenaValida(nueva)) {
      return ResultadoAutenticacion.errorFormato(
        mensaje: 'La contraseña debe ser alfanumérica y tener mínimo 8 caracteres.',
      );
    }

    final usuario = await usuarioRepositorio.buscarPorIdentificador(id);
    if (usuario == null) {
      return ResultadoAutenticacion.usuarioNoExiste(
        mensaje: 'El usuario no existe. Verifique sus datos.',
      );
    }

    // Verificar código
    final esValido = usuario.codigoRecuperacionEsValido(cod);
    if (!esValido) {
      return ResultadoAutenticacion.credencialesInvalidas(
        mensaje: 'Código inválido o expirado. Solicite uno nuevo.',
      );
    }

    // Cambiar contraseña (se permite reutilizar)
    usuario.contrasena = nueva;

    // Desbloquear y reiniciar intentos
    usuario.reiniciarIntentos();

    // Consumir código
    usuario.limpiarCodigoRecuperacion();

    await usuarioRepositorio.actualizarUsuario(usuario);

    return ResultadoAutenticacion.exitoso(
      mensaje: 'Contraseña actualizada. Ya puede iniciar sesión.',
      idUsuario: usuario.id,
      username: usuario.username,
    );
  }

  // =========================
  // Helpers
  // =========================

  String _generarCodigo6Digitos() {
    final random = Random.secure();
    final numero = random.nextInt(900000) + 100000; // 100000 - 999999
    return numero.toString();
  }
}
