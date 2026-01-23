class ValidacionesCasa {
  static bool nombreValido(String nombre) => nombre.trim().isNotEmpty;

  static bool precioValido(double precio) => precio > 0;

  static bool personasValidas(int max) => max > 0;

  static bool habitacionesValidas(int habitaciones) => habitaciones > 0;

  static bool descripcionValida(String descripcion) =>
      descripcion.trim().length >= 10;

  static bool fotosValidas(List<String> fotos) =>
      fotos.isNotEmpty && fotos.length <= 10;

  static bool ubicacionValida(String ubicacion) =>
      ubicacion.trim().isNotEmpty;

  static bool amenidadesValidas(List<int> amenidades) {
    if (amenidades.isEmpty) return false;

    return amenidades.every((id) => id >= 1 && id <= 32);
}

  static bool reglasUsoValidas(List<String> reglas) {
    return reglas.isNotEmpty &&
        reglas.every((r) => r.trim().isNotEmpty);
}

  static bool fechasNoDisponiblesValidas(List<DateTime> fechas) {
    // Puede estar vacía, pero si viene debe ser futura o actual
    return fechas.every((f) =>
        !f.isBefore(DateTime.now().subtract(const Duration(days: 1))));
}
}