import 'package:flutter/material.dart';

/// Paleta de colores centralizada para la aplicación IntelliHome
/// Estos colores son actualizables y persistentes
class AppColors {
  // Colores principales de la paleta
  static Color primaryColor = const Color(0xFFB884F5);      // Morado
  static Color secondaryColor = const Color(0xFF8FA8F7);    // Azul
  static Color tertiaryColor = const Color(0xFF7EDFF2);     // Cian
  static Color accentColor = const Color(0xFF7FF5F0);       // Verde agua

  // Colores adicionales útiles
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color textSecondaryColor = Color(0xFF7F8C8D);
  static const Color borderColor = Color(0xFFBDC3C7);

  /// Actualizar los colores principales
  /// Esto permite que los colores se actualicen en toda la app
  static void updatePrimaryColor(Color color) {
    primaryColor = color;
  }

  static void updateSecondaryColor(Color color) {
    secondaryColor = color;
  }

  static void updateTertiaryColor(Color color) {
    tertiaryColor = color;
  }

  static void updateAccentColor(Color color) {
    accentColor = color;
  }

  /// Resetear a los colores por defecto
  static void resetColors() {
    primaryColor = const Color(0xFFB884F5);
    secondaryColor = const Color(0xFF8FA8F7);
    tertiaryColor = const Color(0xFF7EDFF2);
    accentColor = const Color(0xFF7FF5F0);
  }

  /// Obtener un Color a partir de un valor HEX
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (!hexString.startsWith('#')) buffer.write('#');
    buffer.write(hexString);
    return Color(int.parse(buffer.toString().replaceFirst('#', '0xFF'), radix: 16));
  }

  /// Convertir un Color a su valor HEX
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Crear un tema de Flutter basado en estos colores
  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIconColor: secondaryColor,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: textPrimaryColor,
        ),
        bodySmall: TextStyle(
          color: textSecondaryColor,
        ),
      ),
    );
  }
}
