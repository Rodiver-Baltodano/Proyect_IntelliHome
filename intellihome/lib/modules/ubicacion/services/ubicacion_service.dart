import 'package:geocoding/geocoding.dart';

class UbicacionService {
  Future<String> obtenerProvinciaCanton({
    required double lat,
    required double lng,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return 'Ubicación desconocida';

      final placemark = placemarks.first;
      final provincia = _limpiarProvincia(
        (placemark.administrativeArea ?? '').trim(),
      );
      var canton = _limpiarCanton(
        (placemark.subAdministrativeArea ?? '').trim(),
      );
      if (canton.isEmpty) {
        canton = _limpiarCanton((placemark.locality ?? '').trim());
      }

      if (provincia.isEmpty && canton.isEmpty) {
        return 'Ubicación desconocida';
      }
      if (provincia.isEmpty) return canton;
      if (canton.isEmpty) return provincia;
      return '$provincia, $canton';
    } catch (_) {
      return 'Ubicación desconocida';
    }
  }

  String _limpiarProvincia(String value) {
    return value
        .replaceFirst(
          RegExp(r'^provincia\s+de\s+', caseSensitive: false),
          '',
        )
        .trim();
  }

  String _limpiarCanton(String value) {
    return value
        .replaceFirst(
          RegExp(r'^cant[oó]n\s+de\s+', caseSensitive: false),
          '',
        )
        .trim();
  }
}
