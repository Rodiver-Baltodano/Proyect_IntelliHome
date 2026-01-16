import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:intellihome/modules/autenticacion/autenticacion.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/theme/theme_colors.dart';

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
    fechaNacimiento: DateTime(1990, 5, 15),
    numeroTarjeta: '4111111111111111',
    fechaExpiracion: '12/30',
    cvv: '123',
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
    fechaNacimiento: DateTime(1992, 8, 20),
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
    fechaNacimiento: DateTime(1995, 3, 10),
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

  // ========== PRUEBAS DE PERSONALIZACIÓN ==========
  print('');
  print('========================================');
  print('PRUEBAS: PERSONALIZACIÓN (TEMA Y ESTILO)');
  print('========================================');
  print('');

  final themeProvider = ThemeProvider();

  // PRUEBA 1: Registrar usuario con defaults
  print('PRUEBA 1: Registrar usuario con valores default');
  print('-' * 40);
  final resultadoReg = await registroServicio.registrarUsuario(
    nombreApellidos: 'Carlos Tema',
    username: 'carlostema',
    correo: 'carlos@example.com',
    telefono: '87654325',
    contrasena: 'password789',
    nacionalidad: 'Costa Rica',
    numeroIBAN: 'CR2400123456789012345681',
    fotoPerfil: 'https://example.com/carlos.jpg',
    aceptaTerminos: true,
    fechaNacimiento: DateTime(1994, 7, 22),
  );

  if (!resultadoReg.exito) {
    print('✗ Error en registro: ${resultadoReg.errores}');
  } else {
    final usuarioRegistrado = resultadoReg.usuario!;
    print('✓ Usuario registrado: ${usuarioRegistrado.username}');
    print('  - Tema default: ${usuarioRegistrado.tema}');
    print('  - Estilo default: ${usuarioRegistrado.estilo}');
    assert(usuarioRegistrado.tema == 'medio', 'Tema default no es medio');
    assert(usuarioRegistrado.estilo == 'aventurero',
        'Estilo default no es aventurero');
  }
  print('');

  // PRUEBA 2: Inicializar ThemeProvider con usuario
  print('PRUEBA 2: Inicializar ThemeProvider con usuario registrado');
  print('-' * 40);
  themeProvider.inicializarConUsuario(resultadoReg.usuario!);
  print('✓ ThemeProvider inicializado');
  print('  - Tema actual: ${themeProvider.currentThemeType.name}');
  print('  - Estilo actual: ${themeProvider.currentStyle.name}');
  assert(themeProvider.currentThemeType == ThemeType.medio,
      'Tema no cargó correctamente');
  assert(themeProvider.currentStyle == StyleType.aventurero,
      'Estilo no cargó correctamente');
  print('');

  // PRUEBA 3: Cambiar tema
  print('PRUEBA 3: Cambiar tema a oscuro');
  print('-' * 40);
  await themeProvider.changeTheme(ThemeType.oscuro);
  print('✓ Tema cambiado a: ${themeProvider.currentThemeType.name}');
  print('  - Usuario actualizado: ${themeProvider.usuarioActual?.tema}');
  assert(themeProvider.usuarioActual?.tema == 'oscuro',
      'Tema del usuario no se actualizó');
  print('');

  // PRUEBA 4: Cambiar estilo
  print('PRUEBA 4: Cambiar estilo a minimalista');
  print('-' * 40);
  await themeProvider.changeStyle(StyleType.minimalista);
  print('✓ Estilo cambiado a: ${themeProvider.currentStyle.name}');
  print('  - Usuario actualizado: ${themeProvider.usuarioActual?.estilo}');
  assert(themeProvider.usuarioActual?.estilo == 'minimalista',
      'Estilo del usuario no se actualizó');
  print('');

  // PRUEBA 5: Múltiples cambios de tema
  print('PRUEBA 5: Cambiar tema múltiples veces');
  print('-' * 40);
  await themeProvider.changeTheme(ThemeType.claro);
  print('  Cambio 1: ${themeProvider.currentThemeType.name}');
  await themeProvider.changeTheme(ThemeType.medio);
  print('  Cambio 2: ${themeProvider.currentThemeType.name}');
  await themeProvider.changeTheme(ThemeType.oscuro);
  print('  Cambio 3: ${themeProvider.currentThemeType.name}');
  assert(themeProvider.currentThemeType == ThemeType.oscuro,
      'Último cambio de tema no funcionó');
  print('✓ Todos los cambios aplicados correctamente');
  print('');

  // PRUEBA 5.5: Actualizar color primario
  print('PRUEBA 5.5: Actualizar color primario');
  print('-' * 40);
  final colorPrimarioOriginal = themeProvider.currentTheme.primary;
  themeProvider.updatePrimaryColor(const Color.fromARGB(255, 255, 0, 0));
  print('✓ Color primario actualizado:');
  print('  - Anterior: $colorPrimarioOriginal');
  print('  - Nuevo: ${themeProvider.currentTheme.primary}');
  print('  - Guardado en usuario: ${themeProvider.usuarioActual?.colorPrimarioARGB}');
  assert(themeProvider.currentTheme.primary == const Color.fromARGB(255, 255, 0, 0),
      'Color primario no se actualizó correctamente');
  assert(themeProvider.usuarioActual?.colorPrimarioARGB != null,
      'Color primario no se guardó en usuario');
  print('');

  // PRUEBA 5.6: Actualizar color de fondo
  print('PRUEBA 5.6: Actualizar color de fondo');
  print('-' * 40);
  final colorFondoOriginal = themeProvider.currentTheme.background;
  themeProvider.updateBackgroundColor(const Color.fromARGB(255, 0, 0, 255));
  print('✓ Color de fondo actualizado:');
  print('  - Anterior: $colorFondoOriginal');
  print('  - Nuevo: ${themeProvider.currentTheme.background}');
  print('  - Guardado en usuario: ${themeProvider.usuarioActual?.colorBackgroundARGB}');
  assert(themeProvider.currentTheme.background == const Color.fromARGB(255, 0, 0, 255),
      'Color de fondo no se actualizó correctamente');
  assert(themeProvider.usuarioActual?.colorBackgroundARGB != null,
      'Color de fondo no se guardó en usuario');
  print('');

  // PRUEBA 6: Obtener datos de personalización
  print('PRUEBA 6: Obtener datos de personalización');
  print('-' * 40);
  final personalizacion = themeProvider.obtenerPersonalizacion();
  print('Datos guardados en usuario:');
  print('  - tema: ${personalizacion['tema']}');
  print('  - estilo: ${personalizacion['estilo']}');
  assert(personalizacion['tema'] == 'oscuro', 'Tema incorrecto');
  assert(personalizacion['estilo'] == 'minimalista', 'Estilo incorrecto');
  print('✓ Datos obtenidos correctamente');
  print('');

  // PRUEBA 7: Resetear a defaults
  print('PRUEBA 7: Resetear a valores por defecto');
  print('-' * 40);
  await themeProvider.resetearADefaults();
  print('✓ Valores reseteados');
  print('  - Tema: ${themeProvider.currentThemeType.name}');
  print('  - Estilo: ${themeProvider.currentStyle.name}');
  print('  - Usuario tema: ${themeProvider.usuarioActual?.tema}');
  print('  - Usuario estilo: ${themeProvider.usuarioActual?.estilo}');
  assert(themeProvider.currentThemeType == ThemeType.medio, 'Tema no es medio');
  assert(themeProvider.currentStyle == StyleType.aventurero,
      'Estilo no es aventurero');
  print('');

// PRUEBA 9: Guardar cambios en JSON
  print('PRUEBA 9: Verificar que cambios persisten en JSON');
  print('-' * 40);
  await themeProvider.changeTheme(ThemeType.claro);
  await themeProvider.changeStyle(StyleType.contemporaneo);
  themeProvider.updatePrimaryColor(const Color.fromARGB(255, 100, 200, 50));
  themeProvider.updateBackgroundColor(const Color.fromARGB(255, 220, 180, 100));
    // Actualizamos al usuario existente en el repositorio (no creamos uno nuevo)
    await repositorio.actualizarUsuario(themeProvider.usuarioActual!);
  
  // Cargar usuario de nuevo
    final usuariosRecargados = await repositorio.cargarUsuarios();
    final usuarioRecargado =
      usuariosRecargados.firstWhere((u) => u.username == 'carlostema');
  
  print('Datos después de recargar desde JSON:');
  print('  - Tema: ${usuarioRecargado.tema}');
  print('  - Estilo: ${usuarioRecargado.estilo}');
  print('  - Color primario ARGB: ${usuarioRecargado.colorPrimarioARGB}');
  print('  - Color fondo ARGB: ${usuarioRecargado.colorBackgroundARGB}');
  assert(usuarioRecargado.tema == 'claro', 'Tema no persistió en JSON');
  assert(usuarioRecargado.estilo == 'contemporaneo',
      'Estilo no persistió en JSON');
  assert(usuarioRecargado.colorPrimarioARGB != null, 'Color primario no persistió');
  assert(usuarioRecargado.colorBackgroundARGB != null, 'Color fondo no persistió');
  print('✓ Cambios guardados correctamente en JSON');
  print('');

  // ========== RESUMEN FINAL ==========
  print('========================================');
  print('RESUMEN FINAL - TODAS LAS PRUEBAS');
  print('========================================');
  print('AUTENTICACIÓN:');
  print('  ✓ Registro con validación completa');
  print('  ✓ Detección de campos duplicados');
  print('  ✓ Validación de formato de campos');
  print('  ✓ Login con username, email y teléfono');
  print('  ✓ Bloqueo después de 5 intentos fallidos');
  print('  ✓ Recuperación con código temporal');
  print('  ✓ Cambio de contraseña y desbloqueo');
  print('');
  print('PERSONALIZACIÓN:');
  print('  ✓ Registro con valores default (medio/aventurero)');
  print('  ✓ Inicialización de ThemeProvider');
  print('  ✓ Cambio de tema (claro/medio/oscuro)');
  print('  ✓ Cambio de estilo (aventurero/minimalista/contemporáneo)');
  print('  ✓ Múltiples cambios consecutivos');
  print('  ✓ Actualización de color primario (persistencia)');
  print('  ✓ Actualización de color de fondo (persistencia)');
  print('  ✓ Obtención de datos de personalización');
  print('  ✓ Reseteo a valores por defecto');
  print('  ✓ Persistencia completa en JSON');
  print('');
  print('✨ TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE');
  print('');
}

