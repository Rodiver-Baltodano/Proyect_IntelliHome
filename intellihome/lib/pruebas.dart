import 'dart:io';
import 'dart:convert';

import 'package:intellihome/moduloAutenticacion/modelos/usuario.dart';
import 'package:intellihome/moduloAutenticacion/repositorios/usuario_repositorio_json.dart';
import 'package:intellihome/moduloAutenticacion/servicios/autenticacion_servicio.dart';

Future<void> main() async {
  print('=== PRUEBA LOGIN INTELLIHOME ===');

  // 1) Crear archivo JSON de prueba
  final archivo = File('usuarios_prueba.json');

  final usuarios = [
    Usuario(
      id: 'u1',
      username: 'juan',
      correo: 'juan@mail.com',
      telefono: '88887777',
      contrasena: 'abcd1234',
    ).toJson(),
  ];

  await archivo.writeAsString(
    const JsonEncoder.withIndent('  ').convert(usuarios),
  );

  // 2) Instanciar repositorio y servicio
  final repositorio = UsuarioRepositorioJson(rutaArchivo: archivo.path);
  final servicio = AutenticacionServicio(usuarioRepositorio: repositorio);

  // 3) Login correcto
  print('\n--- Login correcto ---');
  var res = await servicio.iniciarSesion(
    identificador: 'juan',
    contrasena: 'abcd1234',
  );
  print(res.mensaje);

  // 4) Login incorrecto 5 veces
  print('\n--- Login incorrecto 5 veces ---');
  for (int i = 1; i <= 5; i++) {
    res = await servicio.iniciarSesion(
      identificador: 'juan',
      contrasena: 'xxxx9999',
    );
    print('Intento $i: ${res.mensaje}');
  }

  // 5) Intento con contraseña correcta pero bloqueado
  print('\n--- Intento con contraseña correcta estando bloqueado ---');
  res = await servicio.iniciarSesion(
    identificador: 'juan',
    contrasena: 'abcd1234',
  );
  print(res.mensaje);

  // 6) Recuperación de contraseña
  print('\n--- Recuperación de contraseña ---');
  final resCodigo = await servicio.solicitarCodigoRecuperacion(
    identificador: 'juan',
    mostrarCodigoParaPruebas: true,
  );
  print(resCodigo.mensaje);

  final codigo = RegExp(r'(\d{6})').firstMatch(resCodigo.mensaje)!.group(1)!;

  final resCambio = await servicio.actualizarContrasenaConCodigo(
    identificador: 'juan',
    codigo: codigo,
    nuevaContrasena: 'nueva1234',
  );
  print(resCambio.mensaje);

  // 7) Login con nueva contraseña
  print('\n--- Login con nueva contraseña ---');
  res = await servicio.iniciarSesion(
    identificador: 'juan',
    contrasena: 'nueva1234',
  );
  print(res.mensaje);

  print('\n=== FIN PRUEBAS ===');
}
