import 'package:flutter/material.dart';

/// Archivo de definición de colores para los temas de personalización
/// Este archivo contiene las paletas predefinidas que el usuario puede seleccionar

/// Enumeración para identificar los diferentes temas disponibles
enum ThemeType {
  claro,    // Tema claro
  oscuro,   // Tema oscuro
  medio,    // Tema medio (predeterminado)
}

/// Clase que define los colores predeterminados para el tema CLARO
/// Estos colores se usan cuando el usuario selecciona el tema "Claro"
class ClaroThemeColors {
  // Color más oscuro - usado para fondos principales o elementos destacados
  // Azul oscuro profundo
  static const Color primary = Color(0xFF164863);
  
  // Color secundario - usado para elementos interactivos y acentos
  // Azul medio
  static const Color secondary = Color(0xFF427D9D);
  
  // Color terciario - usado para elementos secundarios y fondos suaves
  // Azul claro
  static const Color tertiary = Color(0xFF9BBEC8);
  
  // Color de fondo - usado para fondos generales y superficies
  // Azul muy claro, casi blanco
  static const Color background = Color(0xFFDDF2FD);

  /// Método que retorna todos los colores como una lista
  /// Útil para mostrarlos en un selector de paleta
  static List<Color> getAllColors() {
    return [
      primary,
      secondary,
      tertiary,
      background,
    ];
  }

  /// Método que retorna los nombres descriptivos de cada color
  /// Para mostrar en la UI junto a cada color
  static List<String> getColorNames() {
    return [
      'Primario',
      'Secundario',
      'Terciario',
      'Fondo',
    ];
  }
}

/// Clase que define los colores predeterminados para el tema MEDIO
/// Estos colores se usan cuando el usuario selecciona el tema "Medio"
class MedioThemeColors {
  // Color principal - usado para fondos principales o elementos destacados
  // Púrpura claro vibrante
  static const Color primary = Color(0xFFB983FF);
  
  // Color secundario - usado para elementos interactivos y acentos
  // Azul medio
  static const Color secondary = Color(0xFF94B3FD);
  
  // Color terciario - usado para elementos secundarios y fondos suaves
  // Azul claro
  static const Color tertiary = Color(0xFF94DAFF);
  
  // Color de fondo - usado para fondos generales y superficies
  // Cyan muy claro
  static const Color background = Color(0xFF99FEFF);

  /// Método que retorna todos los colores como una lista
  /// Útil para mostrarlos en un selector de paleta
  static List<Color> getAllColors() {
    return [
      primary,
      secondary,
      tertiary,
      background,
    ];
  }

  /// Método que retorna los nombres descriptivos de cada color
  /// Para mostrar en la UI junto a cada color
  static List<String> getColorNames() {
    return [
      'Primario',
      'Secundario',
      'Terciario',
      'Fondo',
    ];
  }
}

/// Clase que define los colores predeterminados para el tema OSCURO
/// Estos colores se usan cuando el usuario selecciona el tema "Oscuro"
class OscuroThemeColors {
  // Color más oscuro - usado para fondos principales
  // Azul muy oscuro, casi negro
  static const Color primary = Color(0xFF070F2B);
  
  // Color secundario - usado para elementos interactivos y acentos
  // Azul oscuro púrpura
  static const Color secondary = Color(0xFF1B1A55);
  
  // Color terciario - usado para elementos secundarios
  // Gris azulado medio
  static const Color tertiary = Color(0xFF535C91);
  
  // Color de fondo - usado para fondos suaves y superficies elevadas
  // Lavanda claro
  static const Color background = Color(0xFF9290C3);

  /// Método que retorna todos los colores como una lista
  /// Útil para mostrarlos en un selector de paleta
  static List<Color> getAllColors() {
    return [
      primary,
      secondary,
      tertiary,
      background,
    ];
  }

  /// Método que retorna los nombres descriptivos de cada color
  /// Para mostrar en la UI junto a cada color
  static List<String> getColorNames() {
    return [
      'Primario',
      'Secundario',
      'Terciario',
      'Fondo',
    ];
  }
}

/// Clase base para manejar los colores del tema de la aplicación
/// Esta clase se usará para cambiar dinámicamente entre temas
class AppThemeColors {
  // Color principal actual
  final Color primary;
  
  // Color secundario actual
  final Color secondary;
  
  // Color terciario actual
  final Color tertiary;
  
  // Color de fondo actual
  final Color background;

  // Tipo de tema actualmente seleccionado
  final ThemeType themeType;

  /// Constructor que inicializa los colores del tema
  const AppThemeColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.themeType,
  });

  /// Factory constructor para crear el tema CLARO
  factory AppThemeColors.claro() {
    return const AppThemeColors(
      primary: ClaroThemeColors.primary,
      secondary: ClaroThemeColors.secondary,
      tertiary: ClaroThemeColors.tertiary,
      background: ClaroThemeColors.background,
      themeType: ThemeType.claro,
    );
  }

  /// Factory constructor para crear el tema MEDIO
  /// Este es el tema predeterminado de la aplicación
  factory AppThemeColors.medio() {
    return const AppThemeColors(
      primary: MedioThemeColors.primary,
      secondary: MedioThemeColors.secondary,
      tertiary: MedioThemeColors.tertiary,
      background: MedioThemeColors.background,
      themeType: ThemeType.medio,
    );
  }

  /// Factory constructor para crear el tema OSCURO
  factory AppThemeColors.oscuro() {
    return const AppThemeColors(
      primary: OscuroThemeColors.primary,
      secondary: OscuroThemeColors.secondary,
      tertiary: OscuroThemeColors.tertiary,
      background: OscuroThemeColors.background,
      themeType: ThemeType.oscuro,
    );
  }

  /// Método para crear una copia del tema con colores modificados
  /// Permite cambiar solo algunos colores sin afectar los demás
  AppThemeColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? background,
    ThemeType? themeType,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      background: background ?? this.background,
      themeType: themeType ?? this.themeType,
    );
  }

  /// Convierte los colores del tema a un ThemeData de Flutter
  /// Esto permite aplicar el tema a toda la aplicación
  ThemeData toThemeData() {
    return ThemeData(
      // Configuración de la paleta de colores
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: tertiary,
        onTertiary: Colors.black87,
        error: Colors.red,
        onError: Colors.white,
        surface: background,
        onSurface: Colors.black87,
      ),
      
      // Color de fondo general de la aplicación
      scaffoldBackgroundColor: background,
      
      // Configuración de la AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      // Configuración de los botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// Retorna todos los colores como una lista
  List<Color> getAllColors() {
    return [primary, secondary, tertiary, background];
  }
}
