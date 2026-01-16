import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('es', ''); // Español por defecto
  
  Locale get locale => _locale;
  
  // Mapa de banderas a códigos de idioma
  final Map<String, String> _flagToLanguage = {
    'spain_flag.png': 'es',
    'usa_flag.png': 'en',
    'brazil_flag.png': 'pt',
  };
  
  // Mapa inverso: código de idioma a bandera
  final Map<String, String> _languageToFlag = {
    'es': 'spain_flag.png',
    'en': 'usa_flag.png',
    'pt': 'brazil_flag.png',
  };
  
  String get currentFlag => _languageToFlag[_locale.languageCode] ?? 'spain_flag.png';
  
  LanguageProvider() {
    _loadLocale();
  }
  
  // Cargar el idioma guardado
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'es';
    _locale = Locale(languageCode, '');
    notifyListeners();
  }
  
  // Cambiar idioma de manera cíclica
  Future<void> toggleLanguage() async {
    String nextLanguageCode;
    
    switch (_locale.languageCode) {
      case 'es':
        nextLanguageCode = 'en';
        break;
      case 'en':
        nextLanguageCode = 'pt';
        break;
      case 'pt':
        nextLanguageCode = 'es';
        break;
      default:
        nextLanguageCode = 'es';
    }
    
    await setLocale(Locale(nextLanguageCode, ''));
  }
  
  // Establecer un idioma específico
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    
    notifyListeners();
  }
  
  // Obtener nombre del idioma actual
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      default:
        return 'Español';
    }
  }
}