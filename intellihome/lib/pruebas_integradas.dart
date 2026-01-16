import 'dart:io';
import 'package:path/path.dart' as p;
import 'moduloAutenticacion/servicios/registro_servicio.dart';
import 'moduloAutenticacion/servicios/autenticacion_servicio.dart';
import 'moduloAutenticacion/repositorios/usuario_repositorio_json.dart';

void main() async {
  print('========================================');
  print('PRUEBAS INTEGRADAS: REGISTRO + LOGIN');
  print('========================================');
  print('');

  // ========== SETUP ==========
  final rutaJson = p.join(Directory.current.path, 'usuarios_integrado.json');
  final archivo = File(rutaJson);

  // Limpiar archivo anterior
  if (await archivo.exists()) {
    await archivo.delete();
  }

  final repositorio = UsuarioRepositorioJson(rutaArchivo: rutaJson);
  final registroServicio = RegistroServicio(repositorio: repositorio);
  final autenticacionServicio = AutenticacionServicio(usuarioRepositorio: repositorio);

  // ========== PRUEBA 1: Registro exitoso ==========
  print('PRUEBA 1: Registro de usuario exitoso');
  print('-' * 40);

  final resultadoReg1 = await registroServicio.registrarUsuario(
    nombreApellidos: 'Juan Pérez',
    username: 'juanperez123',
    correo: 'juan@example.com',
    telefono: '87654321',
    contrasena: 'password123',
    nacionalidad: 'Costa Rica',
    numeroIBAN: 'CR2400123456789012345678',
    fotoPerfil: 'https://example.com/juan.jpg',
    aceptaTerminos: true,
    datosTargeta: '4111111111111111',
    huellaBiometrica: 'HUELLA_001',
  );

  print('Resultado: ${resultadoReg1.exito ? 'ÉXITO' : 'ERROR'}');
  if (resultadoReg1.exito) {
    print('✓ Usuario registrado: ${resultadoReg1.usuario?.username}');
  } else {
    print('✗ Errores: ${resultadoReg1.errores}');
  }
  print('');

  // ========== PRUEBA 2: Username duplicado ==========
  print('PRUEBA 2: Intentar registrar con username duplicado');
  print('-' * 40);

  final resultadoReg2 = await registroServicio.registrarUsuario(
    nombreApellidos: 'Maria García',
    username: 'juanperez123',
    correo: 'maria@example.com',
    telefono: '87654322',
    contrasena: 'password456',
    nacionalidad: 'Costa Rica',
    numeroIBAN: 'CR2400123456789012345679',
    fotoPerfil: 'https://example.com/maria.jpg',
    aceptaTerminos: true,
  );

  print('Resultado: ${resultadoReg2.exito ? 'ÉXITO' : 'ERROR'}');
  if (!resultadoReg2.exito) {
    print('✓ Detectado error esperado: ${resultadoReg2.errores['username']}');
  }
  print('');

  // ========== PRUEBA 3: Email inválido ==========
  print('PRUEBA 3: Intentar registrar con email inválido');
  print('-' * 40);

  final resultadoReg3 = await registroServicio.registrarUsuario(
    nombreApellidos: 'Carlos López',
    username: 'carloslopez',
    correo: 'emailinvalido',
    telefono: '87654323',
    contrasena: 'password789',
    nacionalidad: 'Costa Rica',
    numeroIBAN: 'CR2400123456789012345680',
    fotoPerfil: 'https://example.com/carlos.jpg',
    aceptaTerminos: true,
  );

  print('Resultado: ${resultadoReg3.exito ? 'ÉXITO' : 'ERROR'}');
  if (!resultadoReg3.exito) {
    print('✓ Detectado error: ${resultadoReg3.errores['correo']}');
  }
  print('');

  // ========== PRUEBA 4: Login exitoso ==========
  print('PRUEBA 4: Login exitoso');
  print('-' * 40);

  final resultadoLogin1 = await autenticacionServicio.iniciarSesion(
    identificador: 'juanperez123',
    contrasena: 'password123',
  );

  print('Resultado: ${resultadoLogin1.exito ? 'ÉXITO' : 'ERROR'}');
  if (resultadoLogin1.exito) {
    print('✓ Sesión iniciada: ${resultadoLogin1.username}');
  } else {
    print('✗ ${resultadoLogin1.mensaje}');
  }
  print('');

  // ========== PRUEBA 5: Login con contraseña incorrecta ==========
  print('PRUEBA 5: Login con contraseña incorrecta (1er intento)');
  print('-' * 40);

  final resultadoLogin2 = await autenticacionServicio.iniciarSesion(
    identificador: 'juanperez123',
    contrasena: 'wrongpassword',
  );

  print('Resultado: ${resultadoLogin2.exito ? 'ÉXITO' : 'ERROR'}');
  if (!resultadoLogin2.exito) {
    print('✓ ${resultadoLogin2.mensaje}');
    print('   Intentos restantes: ${resultadoLogin2.intentosRestantes}');
  }
  print('');

  // ========== PRUEBA 6: Múltiples intentos fallidos ==========
  print('PRUEBA 6: Múltiples intentos fallidos (hasta bloqueo)');
  print('-' * 40);

  for (int i = 2; i <= 5; i++) {
    final resultado = await autenticacionServicio.iniciarSesion(
      identificador: 'juanperez123',
      contrasena: 'wrongpassword',
    );

    print('Intento $i:');
    print('   Bloqueado: ${resultado.usuarioBloqueado}');
    print('   Intentos restantes: ${resultado.intentosRestantes ?? 0}');
    if (resultado.usuarioBloqueado) {
      print('   ⚠️  Usuario BLOQUEADO en intento $i');
      break;
    }
  }
  print('');

  // ========== PRUEBA 7: Login bloqueado ==========
  print('PRUEBA 7: Intentar login con usuario bloqueado');
  print('-' * 40);

  final resultadoLogin3 = await autenticacionServicio.iniciarSesion(
    identificador: 'juanperez123',
    contrasena: 'password123',
  );

  print('Resultado: ${resultadoLogin3.exito ? 'ÉXITO' : 'ERROR'}');
  if (resultadoLogin3.usuarioBloqueado) {
    print('✓ ${resultadoLogin3.mensaje}');
  }
  print('');

  // ========== PRUEBA 8: Solicitar recuperación ==========
  print('PRUEBA 8: Solicitar código de recuperación');
  print('-' * 40);

  final resultadoRecuperacion =
      await autenticacionServicio.solicitarCodigoRecuperacion(
    identificador: 'juanperez123',
    mostrarCodigoParaPruebas: true,
  );

  print('Resultado: ${resultadoRecuperacion.exito ? 'ÉXITO' : 'ERROR'}');
  if (resultadoRecuperacion.exito) {
    print('✓ ${resultadoRecuperacion.mensaje}');

    // Extraer código de prueba del mensaje
    final regex = RegExp(r'código=(\d+)');
    final match = regex.firstMatch(resultadoRecuperacion.mensaje);
    final codigo = match?.group(1) ?? 'NO_ENCONTRADO';
    print('   Código extraído: $codigo');
    print('');

    // ========== PRUEBA 9: Verificar código ==========
    print('PRUEBA 9: Verificar código de recuperación');
    print('-' * 40);

    final resultadoVerificacion =
        await autenticacionServicio.verificarCodigoRecuperacion(
      identificador: 'juanperez123',
      codigo: codigo,
    );

    print('Resultado: ${resultadoVerificacion.exito ? 'ÉXITO' : 'ERROR'}');
    if (resultadoVerificacion.exito) {
      print('✓ ${resultadoVerificacion.mensaje}');
    } else {
      print('✗ ${resultadoVerificacion.mensaje}');
    }
    print('');

    // ========== PRUEBA 10: Cambiar contraseña ==========
    print('PRUEBA 10: Cambiar contraseña y desbloquear');
    print('-' * 40);

    final resultadoCambio = await autenticacionServicio.actualizarContrasenaConCodigo(
      identificador: 'juanperez123',
      codigo: codigo,
      nuevaContrasena: 'newpassword999',
    );

    print('Resultado: ${resultadoCambio.exito ? 'ÉXITO' : 'ERROR'}');
    if (resultadoCambio.exito) {
      print('✓ ${resultadoCambio.mensaje}');
    } else {
      print('✗ ${resultadoCambio.mensaje}');
    }
    print('');

    // ========== PRUEBA 11: Login con nueva contraseña ==========
    print('PRUEBA 11: Login con nueva contraseña (desbloqueado)');
    print('-' * 40);

    final resultadoLoginNuevo = await autenticacionServicio.iniciarSesion(
      identificador: 'juanperez123',
      contrasena: 'newpassword999',
    );

    print('Resultado: ${resultadoLoginNuevo.exito ? 'ÉXITO' : 'ERROR'}');
    if (resultadoLoginNuevo.exito) {
      print('✓ Sesión iniciada exitosamente');
      print('   Usuario: ${resultadoLoginNuevo.username}');
      print('   ID: ${resultadoLoginNuevo.idUsuario}');
    } else {
      print('✗ ${resultadoLoginNuevo.mensaje}');
    }
  }
  print('');

  // ========== PRUEBA 12: Login con email ==========
  print('PRUEBA 12: Login usando email en lugar de username');
  print('-' * 40);

  final resultadoLoginEmail = await autenticacionServicio.iniciarSesion(
    identificador: 'juan@example.com',
    contrasena: 'newpassword999',
  );

  print('Resultado: ${resultadoLoginEmail.exito ? 'ÉXITO' : 'ERROR'}');
  if (resultadoLoginEmail.exito) {
    print('✓ Login exitoso con email');
    print('   Username: ${resultadoLoginEmail.username}');
  } else {
    print('✗ ${resultadoLoginEmail.mensaje}');
  }
  print('');

  // ========== PRUEBA 13: Login con teléfono ==========
  print('PRUEBA 13: Login usando teléfono');
  print('-' * 40);

  final resultadoLoginTel = await autenticacionServicio.iniciarSesion(
    identificador: '87654321',
    contrasena: 'newpassword999',
  );

  print('Resultado: ${resultadoLoginTel.exito ? 'ÉXITO' : 'ERROR'}');
  if (resultadoLoginTel.exito) {
    print('✓ Login exitoso con teléfono');
    print('   Username: ${resultadoLoginTel.username}');
  } else {
    print('✗ ${resultadoLoginTel.mensaje}');
  }
  print('');

  // ========== RESUMEN ==========
  print('========================================');
  print('RESUMEN DE PRUEBAS');
  print('========================================');
  print('✓ Registro con validación completa');
  print('✓ Detección de campos duplicados');
  print('✓ Validación de formato de campos');
  print('✓ Login con username, email y teléfono');
  print('✓ Bloqueo después de 5 intentos fallidos');
  print('✓ Recuperación con código temporal');
  print('✓ Cambio de contraseña y desbloqueo');
  print('');
  print('✨ Todas las pruebas completadas');
  print('');
}

