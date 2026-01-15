import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

/// Provider que maneja el estado del tema de la aplicación
/// Este archivo contiene SOLO la lógica de negocio, sin ninguna interfaz
/// 
/// Responsabilidades:
/// - Mantener el tema actual seleccionado
/// - Permitir cambiar entre temas (claro, oscuro, medio)
/// - Notificar a todos los widgets cuando el tema cambia
/// - Iterar/actualizar colores individuales de forma dinámica
class ThemeProvider extends ChangeNotifier {
  // Tema actual de la aplicación
  // Por defecto inicia con el tema "Medio"
  AppThemeColors _currentTheme = AppThemeColors.medio();

  /// Getter que permite acceder al tema actual desde cualquier widget
  /// Uso: final theme = Provider.of<ThemeProvider>(context).currentTheme;
  AppThemeColors get currentTheme => _currentTheme;

  /// Getter que retorna el tipo de tema actual (claro, oscuro, medio)
  /// Útil para saber qué checkbox marcar en la UI
  ThemeType get currentThemeType => _currentTheme.themeType;

  /// Método para cambiar el tema completo según el tipo seleccionado
  /// Este método se llama cuando el usuario hace clic en los checkboxes
  /// 
  /// Parámetros:
  /// - themeType: El tipo de tema a aplicar (ThemeType.claro, oscuro, medio)
  /// 
  /// Ejemplo de uso desde la UI:
  /// ```dart
  /// Provider.of<ThemeProvider>(context, listen: false)
  ///   .changeTheme(ThemeType.medio);
  /// ```
  void changeTheme(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.claro:
        _currentTheme = AppThemeColors.claro();
        break;
      case ThemeType.oscuro:
        _currentTheme = AppThemeColors.oscuro();
        break;
      case ThemeType.medio:
        _currentTheme = AppThemeColors.medio();
        break;
    }
    
    // Notifica a todos los widgets que escuchan este provider
    // Esto causa que la UI se reconstruya con los nuevos colores
    notifyListeners();
  }

  /// Método para actualizar colores personalizables
  /// SOLO permite cambiar primary y background
  /// Los colores secondary y tertiary se mantienen fijos del tema base
  /// 
  /// Parámetros:
  /// - primary: Nuevo color primario (opcional)
  /// - background: Nuevo color de fondo (opcional)
  /// 
  /// Ejemplo:
  /// ```dart
  /// provider.updateCustomColors(primary: Colors.blue);
  /// ```
  void updateCustomColors({
    Color? primary,
    Color? background,
  }) {
    _currentTheme = _currentTheme.copyWith(
      primary: primary,
      background: background,
      // secondary y tertiary NO se modifican
    );
    
    notifyListeners();
  }

  /// Método para iterar y obtener todos los colores actuales
  /// Retorna una lista con los 4 colores del tema actual
  /// 
  /// Útil para:
  /// - Mostrar una vista previa de la paleta
  /// - Iterar sobre los colores en un ListView/GridView
  /// 
  /// Retorna: [primary, secondary, tertiary, background]
  List<Color> getAllColors() {
    return _currentTheme.getAllColors();
  }

  /// Método para actualizar ambos colores personalizables a la vez
  /// Solo acepta primary y background
  /// 
  /// Parámetros:
  /// - primary: Nuevo color primario
  /// - background: Nuevo color de fondo
  void updateBothCustomColors(Color primary, Color background) {
    _currentTheme = _currentTheme.copyWith(
      primary: primary,
      background: background,
      // secondary y tertiary permanecen sin cambios
    );
    
    notifyListeners();
  }

  /// Método para actualizar un color personalizable por su índice
  /// SOLO permite índices 0 (primary) y 3 (background)
  /// Los índices 1 y 2 (secondary y tertiary) NO son personalizables
  /// 
  /// Parámetros:
  /// - index: 0 para primary, 3 para background
  /// - color: Nuevo color a aplicar
  /// 
  /// Lanza excepción si se intenta modificar secondary (1) o tertiary (2)
  void updateColorByIndex(int index, Color color) {
    switch (index) {
      case 0:
        updateCustomColors(primary: color);
        break;
      case 3:
        updateCustomColors(background: color);
        break;
      case 1:
      case 2:
        throw UnsupportedError(
          'Los colores secondary (índice 1) y tertiary (índice 2) no son personalizables. '
          'Solo se pueden modificar primary (0) y background (3).'
        );
      default:
        throw RangeError('Índice debe ser 0 (primary) o 3 (background)');
    }
  }

  /// Método para resetear el tema a los valores predeterminados
  /// Vuelve a aplicar los colores originales del tema seleccionado
  void resetToDefaults() {
    changeTheme(_currentTheme.themeType);
  }

  /// Obtiene solo los colores personalizables del tema actual
  /// Retorna una lista con [primary, background]
  /// Útil para mostrar solo los colores que el usuario puede modificar
  List<Color> getCustomizableColors() {
    return [
      _currentTheme.primary,
      _currentTheme.background,
    ];
  }

  /// Obtiene los colores fijos que no se pueden personalizar
  /// Retorna una lista con [secondary, tertiary]
  List<Color> getFixedColors() {
    return [
      _currentTheme.secondary,
      _currentTheme.tertiary,
    ];
  }

  /// Método que verifica si el tema actual es un tema predefinido o personalizado
  /// Retorna true si SOLO los colores personalizables (primary y background)
  /// coinciden con los del tema base
  bool isDefaultTheme() {
    final defaultTheme = _getDefaultTheme(_currentTheme.themeType);
    
    return _currentTheme.primary == defaultTheme.primary &&
           _currentTheme.background == defaultTheme.background;
           // No verificamos secondary y tertiary ya que siempre son del tema base
  }

  /// Método privado que obtiene el tema predeterminado según el tipo
  AppThemeColors _getDefaultTheme(ThemeType type) {
    switch (type) {
      case ThemeType.claro:
        return AppThemeColors.claro();
      case ThemeType.oscuro:
        return AppThemeColors.oscuro();
      case ThemeType.medio:
        return AppThemeColors.medio();
    }
  }
}
