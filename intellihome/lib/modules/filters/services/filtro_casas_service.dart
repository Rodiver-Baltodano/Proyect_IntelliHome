import 'package:geolocator/geolocator.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/ubicacion/services/ubicacion_service.dart';

class FiltroCasasService {
  Future<List<Casa>> filtrar({
    required List<Casa> casas,
    bool cercaDeMi = false,
    double? precioMin,
    double? precioMax,
  }) async {
    var resultado = _filtrarPorPrecio(
      casas,
      min: precioMin,
      max: precioMax,
    );

    if (!cercaDeMi) return resultado;

    final posicion = await _obtenerPosicionActual();
    if (posicion == null) return [];

    final ubicacionService = UbicacionService();
    final ubicacionUsuario = await ubicacionService.obtenerProvinciaCanton(
      lat: posicion.latitude,
      lng: posicion.longitude,
    );
    final usuarioParts = _splitProvinciaCanton(ubicacionUsuario);
    if (usuarioParts == null) return [];

    final resultados = await Future.wait(
      resultado.map((casa) async {
        final coords = _parseCoords(casa.ubicacion);
        if (coords == null) return null;
        final ubicacionCasa = await ubicacionService.obtenerProvinciaCanton(
          lat: coords.$1,
          lng: coords.$2,
        );
        final casaParts = _splitProvinciaCanton(ubicacionCasa);
        if (casaParts == null) return null;

        final provinciaMatch =
            _normalize(casaParts.$1) == _normalize(usuarioParts.$1);
        final cantonMatch =
            _normalize(casaParts.$2) == _normalize(usuarioParts.$2);

        return (provinciaMatch && cantonMatch) ? casa : null;
      }),
    );

    return resultados.whereType<Casa>().toList();
  }

  List<Casa> _filtrarPorPrecio(
    List<Casa> casas, {
    double? min,
    double? max,
  }) {
    final minValue = min ?? 0;
    final maxValue = max ?? double.infinity;
    return casas
        .where(
          (casa) =>
              casa.precioPorNoche >= minValue && casa.precioPorNoche <= maxValue,
        )
        .toList();
  }

  Future<Position?> _obtenerPosicionActual() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }

  (double, double)? _parseCoords(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  (String, String)? _splitProvinciaCanton(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'ubicación desconocida') {
      return null;
    }
    final parts = cleaned.split(',');
    if (parts.length < 2) return null;
    final provincia = parts[0].trim();
    final canton = parts[1].trim();
    if (provincia.isEmpty || canton.isEmpty) return null;
    return (provincia, canton);
  }

  String _normalize(String value) {
    final lower = value.toLowerCase().trim();
    const accents = 'áéíóúüñ';
    const replacements = 'aeiouun';
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final idx = accents.indexOf(char);
      buffer.write(idx >= 0 ? replacements[idx] : char);
    }
    return buffer.toString();
  }
}
