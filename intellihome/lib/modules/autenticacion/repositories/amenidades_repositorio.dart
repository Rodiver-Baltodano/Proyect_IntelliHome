import 'dart:convert';
import 'package:flutter/services.dart';

class AmenidadesRepositorio {
  /// Carga las amenidades desde el JSON
  static Future<Map<int, String>> cargarAmenidades() async {
    final jsonString =
        await rootBundle.loadString('lib/assets/Data/amenidades.json');

    final List<dynamic> data = json.decode(jsonString);

    return {
      for (final item in data)
        item['id'] as int: item['nombre'] as String,
    };
  }
}
