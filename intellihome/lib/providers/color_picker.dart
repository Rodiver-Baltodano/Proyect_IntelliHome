import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'theme_provider.dart';

/// Helper para mostrar color picker con rueda de colores
class ColorPickerHelper {
  /// Muestra diálogo con rueda de colores para seleccionar color primario
  static void showPrimaryColorPicker(
    BuildContext context,
    ThemeProvider provider,
  ) {
    _showColorPickerDialog(
      context: context,
      title: 'Color Primario',
      currentColor: provider.currentTheme.primary,
      onColorChanged: (color) {
        provider.updateCustomColors(primary: color);
      },
    );
  }

  /// Muestra diálogo con rueda de colores para seleccionar color de fondo
  static void showBackgroundColorPicker(
    BuildContext context,
    ThemeProvider provider,
  ) {
    _showColorPickerDialog(
      context: context,
      title: 'Color de Fondo',
      currentColor: provider.currentTheme.background,
      onColorChanged: (color) {
        provider.updateCustomColors(background: color);
      },
    );
  }

  /// Diálogo privado compartido
  static void _showColorPickerDialog({
    required BuildContext context,
    required String title,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecciona $title'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}