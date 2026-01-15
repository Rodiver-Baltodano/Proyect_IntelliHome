import 'modules/registro/registro.dart';

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║     PRUEBAS DEL MÓDULO DE REGISTRO DE USUARIOS            ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  final manager = RegistroManager();

  // ============ PRUEBA 1: Registro exitoso ============
  print('📝 PRUEBA 1: Registro exitoso');
  print('─' * 60);
  var resultado = await manager.registrarUsuario(
    nombreApellidos: 'Juan Carlos Perez Lopez',
    username: 'juancarlospz',
    fotoPerfil: '/assets/fotos/juan.jpg',
    email: 'juan.carlos@example.com',
    telefono: '+34612345678',
    nacionalidad: 'Espana',
    numeroIBAN: 'ES9121000418450200051332',
    aceptaTerminos: true,
    contrasena: 'MiPassword123',
    datosTargeta: null,
    huellaBiometrica: null,
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 2: Registro exitoso con datos opcionales ============
  print('📝 PRUEBA 2: Registro con datos de tarjeta');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Maria Garcia Sanchez',
    username: 'mariagarcia',
    fotoPerfil: '/assets/fotos/maria.jpg',
    email: 'maria.garcia@example.com',
    telefono: '+34687654321',
    nacionalidad: 'Mexico',
    numeroIBAN: 'MX0910050000012345678900',
    aceptaTerminos: true,
    contrasena: 'SecurePass456',
    datosTargeta: '4532123456789012',
    huellaBiometrica: null,
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 3: Username duplicado ============
  print('📝 PRUEBA 3: Intento de registro con username duplicado');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Otro Usuario Mas',
    username: 'juancarlospz', // Username ya existe
    fotoPerfil: '/assets/fotos/otro.jpg',
    email: 'otro@example.com',
    telefono: '+34698765432',
    nacionalidad: 'Colombia',
    numeroIBAN: 'CO9300760001000193830663',
    aceptaTerminos: true,
    contrasena: 'OtherPass789',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 4: Email duplicado ============
  print('📝 PRUEBA 4: Intento de registro con email duplicado');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Usuario Tercero',
    username: 'usuariotercero',
    fotoPerfil: '/assets/fotos/tercero.jpg',
    email: 'juan.carlos@example.com', // Email ya existe
    telefono: '+34645678901',
    nacionalidad: 'Argentina',
    numeroIBAN: 'AR9001514017940030003439',
    aceptaTerminos: true,
    contrasena: 'NewPassword321',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 5: Contraseña muy corta ============
  print('📝 PRUEBA 5: Contraseña menor a 8 caracteres');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Pedro Rodriguez Garcia',
    username: 'pedrorod',
    fotoPerfil: '/assets/fotos/pedro.jpg',
    email: 'pedro.rodriguez@example.com',
    telefono: '+34756890123',
    nacionalidad: 'Chile',
    numeroIBAN: 'CL9301234567890123456789',
    aceptaTerminos: true,
    contrasena: 'Short1', // Menos de 8 caracteres
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 6: Email inválido ============
  print('📝 PRUEBA 6: Email con formato inválido');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Ana Martinez Lopez',
    username: 'anamartinez',
    fotoPerfil: '/assets/fotos/ana.jpg',
    email: 'email_invalido.com', // Falta @
    telefono: '+34834567890',
    nacionalidad: 'Peru',
    numeroIBAN: 'PE3950000000000000123456',
    aceptaTerminos: true,
    contrasena: 'ValidPass123',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 7: Teléfono inválido ============
  print('📝 PRUEBA 7: Teléfono con formato inválido');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Carlos Fernandez Ruiz',
    username: 'carlosfz',
    fotoPerfil: '/assets/fotos/carlos.jpg',
    email: 'carlos.fernandez@example.com',
    telefono: '12345', // Muy corto
    nacionalidad: 'Venezuela',
    numeroIBAN: 'VE00012345678901234567',
    aceptaTerminos: true,
    contrasena: 'AnotherPass456',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 8: Sin aceptar términos ============
  print('📝 PRUEBA 8: Registro sin aceptar términos');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Laura Jimenez Santos',
    username: 'laurajimenez',
    fotoPerfil: '/assets/fotos/laura.jpg',
    email: 'laura.jimenez@example.com',
    telefono: '+34912345678',
    nacionalidad: 'Ecuador',
    numeroIBAN: 'EC9401234567890123456789',
    aceptaTerminos: false, // NO acepta términos
    contrasena: 'SafePassword789',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 9: Username inválido ============
  print('📝 PRUEBA 9: Username con caracteres inválidos');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Roberto Diaz Morales',
    username: 'user@inv', // Caracteres no permitidos (@ y espacios en menos de 3)
    fotoPerfil: '/assets/fotos/roberto.jpg',
    email: 'roberto.diaz@example.com',
    telefono: '+34923456789',
    nacionalidad: 'Paraguay',
    numeroIBAN: 'PY9902000500020628633013',
    aceptaTerminos: true,
    contrasena: 'RobertoPass123',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
  print('');

  // ============ PRUEBA 10: IBAN inválido ============
  print('📝 PRUEBA 10: IBAN con formato inválido');
  print('─' * 60);
  resultado = await manager.registrarUsuario(
    nombreApellidos: 'Sofia Mendoza Gutierrez',
    username: 'sofiamendoza',
    fotoPerfil: '/assets/fotos/sofia.jpg',
    email: 'sofia.mendoza@example.com',
    telefono: '+34934567890',
    nacionalidad: 'Bolivia',
    numeroIBAN: 'INVALID123', // IBAN inválido
    aceptaTerminos: true,
    contrasena: 'SofiaPass456',
  );
  print('Resultado: ${resultado.exito ? '✓ ÉXITO' : '✗ ERROR'}');
  if (!resultado.exito) {
    resultado.errores.forEach((campo, mensaje) {
      print('  ❌ $campo: $mensaje');
    });
  }
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
