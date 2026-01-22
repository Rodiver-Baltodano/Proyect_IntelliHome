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
}
