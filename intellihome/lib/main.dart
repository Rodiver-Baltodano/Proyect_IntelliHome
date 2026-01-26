import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intellihome/screens/auth/login_screen.dart';
import 'package:intellihome/screens/auth/register_screen.dart';
import 'package:intellihome/screens/auth/recovery_screen.dart';
import 'package:intellihome/screens/auth/terms_screen.dart';
import 'package:intellihome/screens/home/home_screen.dart';
import 'package:intellihome/screens/home/anadir_casa_screen.dart';
import 'package:intellihome/screens/personalizacion/personalization_screen.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/providers/language_provider.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'dart:io';

// ============================================
// CONFIGURACIÓN DE MODO DE PRUEBA
// ============================================
const bool MODO_PRUEBA_LIMPIAR_DATOS = false;
// ============================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  // Limpiar registros de usuario cada vez que se compila la app (solo si está en modo prueba)
  if (MODO_PRUEBA_LIMPIAR_DATOS) {
    await _limpiarDatosUsuarios();
  }
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  UsuarioRepositorioJson? _repositorio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
        _repositorio = UsuarioRepositorioJson(rutaArchivo: rutaJson);
        if (mounted) {
          context.read<ThemeProvider>().setRepositorio(_repositorio!);
        }
      } catch (e) {
        // Solo loggear; el provider seguirá con defaults si falla
        print('Error configurando repositorio en ThemeProvider: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Builder(
        builder: (context) {
          final theme = context.watch<ThemeProvider>().themeData;
          final languageProvider = context.watch<LanguageProvider>();
          
          return MaterialApp(
            title: 'IntelliHome',
            debugShowCheckedModeBanner: false,
            theme: theme,
            
            // Configuración de localización
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            
            home: const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/recovery': (context) {
                final username = ModalRoute.of(context)?.settings.arguments as String?;
                return RecoveryScreen(username: username);
              },
              '/terms': (context) => const TermsUI(),
              '/personalizacion': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                final username = args?['username'] as String? ?? 'Usuario';
                final fromRegister = args?['fromRegister'] as bool? ?? true;
                return PersonalizationScreen(
                  username: username,
                  fromRegister: fromRegister,
                );
              },
              '/home': (context) {
                final username = ModalRoute.of(context)?.settings.arguments as String?;
                return HomeScreen(username: username ?? 'Usuario');
              },
              '/anadir_casa': (context) => const AnadirCasaScreen(),
            },
          );
        },
      ),
    );
  }
}