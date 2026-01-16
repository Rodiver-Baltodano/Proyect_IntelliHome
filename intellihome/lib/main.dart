import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:intellihome/providers/language_provider.dart';
import 'package:intellihome/providers/theme_provider.dart';
// Importa tus screens aquí
import 'package:intellihome/screens/auth/login_screen.dart';
import 'package:intellihome/screens/auth/register_screen.dart';
import 'package:intellihome/screens/auth/recovery_screen.dart';
import 'package:intellihome/screens/home/home_screen.dart';
import 'package:intellihome/screens/personalizacion/personalization_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Agrega otros providers que necesites
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'IntelliHome',
          debugShowCheckedModeBanner: false,
          
          // Configuración de localización
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          
          home: const LoginScreen(),
          
          // Tus rutas aquí
          routes: {
            '/login': (context) => const LoginScreen(),
            // '/register': (context) => const RegisterScreen(),
            // '/recovery': (context) => const RecoveryScreen(),
            // etc...
          },
        );
      },
    );
  }
}