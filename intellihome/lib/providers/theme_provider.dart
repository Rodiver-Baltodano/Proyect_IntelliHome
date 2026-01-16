import 'package:flutter/material.dart';
import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/theme/theme_colors.dart';

enum StyleType {
  aventurero,
  minimalista,
  contemporaneo,
}

/// ThemeProvider: Gestiona tema y estilo del usuario logueado
/// Trabaja directamente con el modelo Usuario y permite guardar en JSON
class ThemeProvider extends ChangeNotifier {
  Usuario? _usuarioActual;
  AppThemeColors _currentTheme = AppThemeColors.medio();
  StyleType _currentStyle = StyleType.minimalista;

  // ========== GETTERS ==========

  /// Usuario actualmente logueado
  Usuario? get usuarioActual => _usuarioActual;

  /// Tema actual (colores)
  AppThemeColors get currentTheme => _currentTheme;

  /// Tipo de tema actual (claro/medio/oscuro)
  ThemeType get currentThemeType => _currentTheme.themeType;

  /// ThemeData para MaterialApp
  ThemeData get themeData => _currentTheme.toThemeData();

  /// Estilo actual (aventurero/minimalista/contemporaneo)
  StyleType get currentStyle => _currentStyle;

  // ========== MÉTODOS PRINCIPALES ==========

  /// Inicializa el provider con un usuario logueado
  /// Carga su tema y estilo guardados
  void inicializarConUsuario(Usuario usuario) {
    _usuarioActual = usuario;
    _cargarTemaDelUsuario(usuario);
    notifyListeners();
  }

  /// Carga el tema y estilo del usuario desde sus datos
  void _cargarTemaDelUsuario(Usuario usuario) {
    // Cargar tema
    final temaString = usuario.tema.toLowerCase();
    switch (temaString) {
      case 'claro':
        _currentTheme = AppThemeColors.claro();
        break;
      case 'oscuro':
        _currentTheme = AppThemeColors.oscuro();
        break;
      case 'medio':
      default:
        _currentTheme = AppThemeColors.medio();
        break;
    }

    // Cargar estilo
    final estiloString = usuario.estilo.toLowerCase();
    switch (estiloString) {
      case 'aventurero':
        _currentStyle = StyleType.aventurero;
        break;
      case 'minimalista':
        _currentStyle = StyleType.minimalista;
        break;
      case 'contemporaneo':
        _currentStyle = StyleType.contemporaneo;
        break;
      default:
        _currentStyle = StyleType.aventurero;
        break;
    }
  }

  /// Cambia el tema y lo persiste en el usuario
  /// USO: provider.changeTheme(ThemeType.oscuro);
  Future<void> changeTheme(ThemeType themeType) async {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    switch (themeType) {
      case ThemeType.claro:
        _currentTheme = AppThemeColors.claro();
        _usuarioActual!.tema = 'claro';
        break;
      case ThemeType.oscuro:
        _currentTheme = AppThemeColors.oscuro();
        _usuarioActual!.tema = 'oscuro';
        break;
      case ThemeType.medio:
        _currentTheme = AppThemeColors.medio();
        _usuarioActual!.tema = 'medio';
        break;
    }
    notifyListeners();
  }

  /// Cambia el estilo y lo persiste en el usuario
  /// USO: provider.changeStyle(StyleType.minimalista);
  Future<void> changeStyle(StyleType styleType) async {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    _currentStyle = styleType;
    _usuarioActual!.estilo = styleType.name;
    notifyListeners();
  }

  /// Obtiene los datos de personalización actual del usuario
  /// RETORNA: {'tema': 'oscuro', 'estilo': 'minimalista'}
  Map<String, String> obtenerPersonalizacion() {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    return {
      'tema': _usuarioActual!.tema,
      'estilo': _usuarioActual!.estilo,
    };
  }

  /// Reinicia el tema y estilo a los valores por defecto
  /// Default: tema='medio', estilo='aventurero'
  Future<void> resetearADefaults() async {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    _currentTheme = AppThemeColors.medio();
    _currentStyle = StyleType.aventurero;
    _usuarioActual!.tema = 'medio';
    _usuarioActual!.estilo = 'aventurero';
    notifyListeners();
  }

  /// Actualiza colores personalizados del tema actual
  /// USO: provider.updateCustomColors(primary: Colors.red);
  /// PARÁMETROS: primary, secondary, background, text (todos opcionales)
  void updateCustomColors({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? text,
  }) {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    // Actualizar colores en el tema actual
    if (primary != null) {
      _currentTheme.primary = primary;
    }
    if (secondary != null) {
      _currentTheme.secondary = secondary;
    }
    if (background != null) {
      _currentTheme.background = background;
    }
    if (text != null) {
      _currentTheme.textColor = text;
    }

    notifyListeners();
  }

  /// Limpia el usuario actual (logout)
  void limpiar() {
    _usuarioActual = null;
    _currentTheme = AppThemeColors.medio();
    _currentStyle = StyleType.aventurero;
    notifyListeners();
  }
}
