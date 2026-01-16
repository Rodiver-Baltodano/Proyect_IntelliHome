import 'package:flutter/material.dart';
import 'package:intellihome/screens/auth/login_screen.dart';
import 'package:intellihome/screens/auth/register_screen.dart';
import 'package:intellihome/screens/auth/recovery_screen.dart';
import 'package:intellihome/screens/home/home_screen.dart';
import 'package:intellihome/config/app_colors.dart';

void main() {
  runApp(const MainApp());
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
