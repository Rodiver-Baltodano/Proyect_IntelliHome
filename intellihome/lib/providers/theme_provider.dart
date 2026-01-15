import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_colors.dart';

/// VARIABLES PARA UI (Líneas marcadas con // UI:)
/// ────────────────────────────────────────────────────────────────────
/// • currentTheme.primary      (L30) - Color primario (EDITABLE)
/// • currentTheme.background   (L30) - Color de fondo (EDITABLE)
/// • currentTheme.secondary    (L30) - Color secundario (SOLO LECTURA)
/// • currentTheme.tertiary     (L30) - Color terciario (SOLO LECTURA)
/// • currentThemeType          (L33) - Tipo actual: claro/medio/oscuro
/// 
/// MÉTODOS PARA UI
/// ────────────────────────────────────────────────────────────────────
/// • changeTheme(tipo)              (L36) - Cambiar tema base
/// • updateCustomColors(...)        (L51) - Cambiar color personalizable
/// • getCustomizableColors()        (L74) - Obtener [primary, background]
/// • getFixedColors()               (L78) - Obtener [secondary, tertiary]
/// • getAllColors()                 (L82) - Obtener todos los colores
/// • resetToDefaults()              (L86) - Restaurar valores predeterminados
/// • isDefaultTheme()               (L90) - Verificar si fue personalizado
/// ═══════════════════════════════════════════════════════════════════════

enum StyleType {
  aventurero,
  minimalista,
  contemporaneo,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeColors _currentTheme = AppThemeColors.medio();
  StyleType _currentStyle = StyleType.minimalista;

  // UI: Acceso al tema completo (primary, secondary, tertiary, background)
  AppThemeColors get currentTheme => _currentTheme;

  // UI: Tipo de tema actual para checkboxes (ThemeType.claro/medio/oscuro)
  ThemeType get currentThemeType => _currentTheme.themeType;

  // UI: ThemeData para aplicar en MaterialApp.theme
  ThemeData get themeData => _currentTheme.toThemeData();

  // UI: Cambiar tema base desde checkboxes
  // Uso: provider.changeTheme(ThemeType.medio)
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
    notifyListeners();
  }

  // UI: Personalizar colores con color picker
  // Uso: provider.updateCustomColors(primary: color) 
  // NOTA: Solo primary y background son editables
  void updateCustomColors({
    Color? primary,
    Color? background,
  }) {
    _currentTheme = _currentTheme.copyWith(
      primary: primary,
      background: background,
    );
    notifyListeners();
  }

  // UI: Actualizar ambos colores personalizables a la vez
  // Uso: provider.updateBothCustomColors(Colors.blue, Colors.white)
  void updateBothCustomColors(Color primary, Color background) {
    _currentTheme = _currentTheme.copyWith(
      primary: primary,
      background: background,
    );
    notifyListeners();
  }

  // UI: Obtener colores EDITABLES [primary, background]
  List<Color> getCustomizableColors() {
    return [_currentTheme.primary, _currentTheme.background];
  }

  // UI: Obtener colores FIJOS [secondary, tertiary] (solo lectura)
  List<Color> getFixedColors() {
    return [_currentTheme.secondary, _currentTheme.tertiary];
  }

  // UI: Obtener TODOS los colores [primary, secondary, tertiary, background]
  List<Color> getAllColors() {
    return _currentTheme.getAllColors();
  }

  // UI: Resetear a colores predeterminados del tema actual
  void resetToDefaults() {
    changeTheme(_currentTheme.themeType);
  }

  // UI: Verificar si el tema fue personalizado (true = sin cambios)
  bool isDefaultTheme() {
    final defaultTheme = _getDefaultTheme(_currentTheme.themeType);
    return _currentTheme.primary == defaultTheme.primary &&
           _currentTheme.background == defaultTheme.background;
  }

  // INTERNO: Actualizar color por índice (0=primary, 3=background)
  // ADVERTENCIA: Lanza error si se intenta modificar índice 1 o 2
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

  // INTERNO: Obtener tema predeterminado por tipo
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

  StyleType get currentStyle => _currentStyle;

  void changeStyle(StyleType styleType) {
    _currentStyle = styleType;
    notifyListeners();
  }

  Future<void> confirmChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_type', _currentTheme.themeType.name);
      await prefs.setString('style_type', _currentStyle.name);
      await prefs.setInt('primary_color', _currentTheme.primary.value);
      await prefs.setInt('background_color', _currentTheme.background.value);

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error al guardar las preferencias de tema/estilo: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar tema
      final themeTypeName = prefs.getString('theme_type');
      if (themeTypeName != null) {
        final themeType = ThemeType.values.firstWhere(
          (e) => e.name == themeTypeName,
          orElse: () => ThemeType.medio,
        );
        changeTheme(themeType);
      }
      
      // Cargar estilo
      final styleTypeName = prefs.getString('style_type');
      if (styleTypeName != null) {
        _currentStyle = StyleType.values.firstWhere(
          (e) => e.name == styleTypeName,
          orElse: () => StyleType.minimalista,
        );
      }
      
      // Cargar colores
      final primaryValue = prefs.getInt('primary_color');
      final backgroundValue = prefs.getInt('background_color');
      if (primaryValue != null && backgroundValue != null) {
        _currentTheme = _currentTheme.copyWith(
          primary: Color(primaryValue),
          background: Color(backgroundValue),
        );
      }
      
      _isRegistrationComplete =
          prefs.getBool('registration_complete') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load theme from SharedPreferences: $e');
      // In case of error, keep defaults and do not crash.
    }
  }

  bool _isRegistrationComplete = false;

  bool get isRegistrationComplete => _isRegistrationComplete;

  Future<void> completeRegistration() async {
    try {
      _isRegistrationComplete = true;
      await confirmChanges();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registration_complete', true);
      notifyListeners();
    } catch (e, stackTrace) {
      _isRegistrationComplete = false;
      debugPrint('Error completing registration: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}
