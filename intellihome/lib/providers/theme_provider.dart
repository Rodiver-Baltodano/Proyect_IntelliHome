import 'package:flutter/material.dart';
import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/theme/theme_colors.dart';
import 'package:intellihome/config/app_colors.dart';

enum StyleType {
  aventurero,
  minimalista,
  contemporaneo,
}

/// ThemeProvider: Gestiona tema y estilo del usuario logueado
/// - Cada tema (claro/medio/oscuro) tiene 4 colores: primario, secundario, terciario, background
/// - Solo 2 métodos para personalizar: updatePrimaryColor() y updateBackgroundColor()
/// - Los cambios se guardan en Usuario y persisten en JSON
class ThemeProvider extends ChangeNotifier {
  Usuario? _usuarioActual;
  AppThemeColors _currentTheme = AppThemeColors.medio();
  StyleType _currentStyle = StyleType.aventurero;
  UsuarioRepositorioJson? _repositorio;

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
  /// Carga su tema, estilo y colores personalizados guardados
  void inicializarConUsuario(Usuario usuario, {UsuarioRepositorioJson? repositorio}) {
    _usuarioActual = usuario;
    _repositorio = repositorio ?? _repositorio;
    _cargarTemaDelUsuario(usuario);
    _cargarColoresPersonalizados(usuario);
    // Solo sincronizar cuando hay usuario logueado
    if (_usuarioActual != null) {
      _syncAppColors();
    }
    notifyListeners();
  }

  /// Permite inyectar un repositorio para persistir cambios en JSON
  void setRepositorio(UsuarioRepositorioJson repositorio) {
    _repositorio = repositorio;
  }

  Future<void> _persistirUsuario() async {
    if (_usuarioActual != null && _repositorio != null) {
      await _repositorio!.actualizarUsuario(_usuarioActual!);
    }
  }

  void _syncAppColors() {
    // Solo sincronizar si hay usuario logueado
    if (_usuarioActual == null) return;
    
    AppColors.updatePrimaryColor(_currentTheme.primary);
    AppColors.updateSecondaryColor(_currentTheme.secondary);
    AppColors.updateTertiaryColor(_currentTheme.tertiary);
    AppColors.updateAccentColor(_currentTheme.tertiary);
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

  /// Carga colores personalizados del usuario si existen
  void _cargarColoresPersonalizados(Usuario usuario) {
    if (usuario.colorPrimarioARGB != null) {
      _currentTheme.primary = Color(usuario.colorPrimarioARGB!);
    }
    if (usuario.colorBackgroundARGB != null) {
      _currentTheme.background = Color(usuario.colorBackgroundARGB!);
    }
  }

  /// Cambia el tema SIN persistir (para preview en PersonalizationScreen)
  void changeThemePreview(ThemeType themeType) {
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
    // Actualizar AppColors para que se vea en todas las vistas
    AppColors.updatePrimaryColor(_currentTheme.primary);
    AppColors.updateSecondaryColor(_currentTheme.secondary);
    AppColors.updateTertiaryColor(_currentTheme.tertiary);
    AppColors.updateAccentColor(_currentTheme.tertiary);
    notifyListeners();
  }

  /// Cambia el tema y lo persiste en el usuario (limpia colores personalizados)
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
    // Limpiar colores personalizados al cambiar tema
    _usuarioActual!.colorPrimarioARGB = null;
    _usuarioActual!.colorBackgroundARGB = null;
    await _persistirUsuario();
    _syncAppColors();
    notifyListeners();
  }

  /// Cambia el estilo SIN persistir (para preview)
  void changeStylePreview(StyleType styleType) {
    _currentStyle = styleType;
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
    await _persistirUsuario();
    notifyListeners();
  }

  /// Actualiza el color primario SIN persistir (para preview)
  void updatePrimaryColorPreview(Color color) {
    _currentTheme.primary = color;
    AppColors.updatePrimaryColor(color);
    notifyListeners();
  }

  /// Actualiza el color de fondo SIN persistir (para preview)
  void updateBackgroundColorPreview(Color color) {
    _currentTheme.background = color;
    AppColors.updateSecondaryColor(color);
    notifyListeners();
  }

  /// Actualiza el color primario del tema actual
  /// Guarda el cambio en el usuario como int ARGB
  /// USO: provider.updatePrimaryColor(Color(0xFF123456));
  void updatePrimaryColor(Color color) {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    _currentTheme.primary = color;
    _usuarioActual!.colorPrimarioARGB = color.value;
    _persistirUsuario();
    _syncAppColors();
    notifyListeners();
  }

  /// Actualiza el color de fondo del tema actual
  /// Guarda el cambio en el usuario como int ARGB
  /// USO: provider.updateBackgroundColor(Color(0xFFABCDEF));
  void updateBackgroundColor(Color color) {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    _currentTheme.background = color;
    _usuarioActual!.colorBackgroundARGB = color.value;
    _persistirUsuario();
    _syncAppColors();
    notifyListeners();
  }

  /// Guarda todos los cambios actuales en el usuario y persiste en JSON
  Future<void> guardarCambios(String tema, String estilo) async {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    _usuarioActual!.tema = tema;
    _usuarioActual!.estilo = estilo;
    _usuarioActual!.colorPrimarioARGB = _currentTheme.primary.value;
    _usuarioActual!.colorBackgroundARGB = _currentTheme.background.value;
    
    await _persistirUsuario();
    _syncAppColors();
  }

  /// Obtiene los datos de personalización actual del usuario
  /// RETORNA: {'tema': 'oscuro', 'estilo': 'minimalista', 'colorPrimario': '4294901760', 'colorBackground': '4294967295'}
  Map<String, String> obtenerPersonalizacion() {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    return {
      'tema': _usuarioActual!.tema,
      'estilo': _usuarioActual!.estilo,
      'colorPrimario': _usuarioActual!.colorPrimarioARGB?.toString() ?? 'default',
      'colorBackground': _usuarioActual!.colorBackgroundARGB?.toString() ?? 'default',
    };
  }

  /// Reinicia el tema y estilo a los valores por defecto
  /// Default: tema='medio', estilo='aventurero', sin colores personalizados
  Future<void> resetearADefaults() async {
    if (_usuarioActual == null) {
      throw Exception('No hay usuario logueado');
    }

    _currentTheme = AppThemeColors.medio();
    _currentStyle = StyleType.aventurero;
    _usuarioActual!.tema = 'medio';
    _usuarioActual!.estilo = 'aventurero';
    _usuarioActual!.colorPrimarioARGB = null;
    _usuarioActual!.colorBackgroundARGB = null;
    await _persistirUsuario();
    _syncAppColors();
    notifyListeners();
  }

  /// Limpia el usuario actual (logout)
  void limpiar() {
    _usuarioActual = null;
    _currentTheme = AppThemeColors.medio();
    _currentStyle = StyleType.aventurero;
    // Resetear AppColors a defaults al desloguearse
    AppColors.resetColors();
    notifyListeners();
  }
}
