import 'package:flutter/material.dart';
import 'package:intellihome/screens/auth/login_screen.dart';
import 'package:intellihome/screens/auth/register_screen.dart';
import 'package:intellihome/screens/auth/recovery_screen.dart';
import 'package:intellihome/screens/home/home_screen.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Limpiar registros de usuario cada vez que se compila la app
  await _limpiarDatosUsuarios();
  runApp(const MainApp());
}

/// Elimina el archivo de usuarios para empezar con una pizarra limpia
Future<void> _limpiarDatosUsuarios() async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
    final archivo = File(rutaJson);

    print('🔍 [LIMPIEZA] Buscando archivo en: $rutaJson');

    if (await archivo.exists()) {
      await archivo.delete();
      print('✅ [LIMPIEZA] Archivo de usuarios eliminado exitosamente.');
    } else {
      print('ℹ️ [LIMPIEZA] No hay archivo previo de usuarios.');
    }
  } catch (e) {
    print('❌ [LIMPIEZA] Error al limpiar datos: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelliHome',
      theme: AppColors.getThemeData(),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/recovery': (context) {
          // Extraer username de los argumentos
          final username = ModalRoute.of(context)?.settings.arguments as String?;
          return RecoveryScreen(username: username);
        },
        '/home': (context) {
          // Extraer username de los argumentos
          final username = ModalRoute.of(context)?.settings.arguments as String?;
          return HomeScreen(username: username ?? 'Usuario');
        },
      },
    );
  }
}
