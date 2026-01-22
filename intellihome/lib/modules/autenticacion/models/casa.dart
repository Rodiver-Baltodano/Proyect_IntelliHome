class Casa {
  final String id;
  final String nombre;
  final double precioPorNoche;
  final int maxPersonas;
  final int habitaciones;
  final String descripcion;
  final List<String> fotos;
  final String ubicacion;
  final List<String> reglasUso;
  final List<String> amenidades;
  final DateTime fechaRegistro;

  Casa({
    required this.id,
    required this.nombre,
    required this.precioPorNoche,
    required this.maxPersonas,
    required this.habitaciones,
    required this.descripcion,
    required this.fotos,
    required this.ubicacion,
    required this.reglasUso,
    required this.amenidades,
    required this.fechaRegistro,
  });

  factory Casa.fromJson(Map<String, dynamic> json) {
    return Casa(
      id: json['id'],
      nombre: json['nombre'],
      precioPorNoche: (json['precioPorNoche'] as num).toDouble(),
      maxPersonas: json['maxPersonas'],
      habitaciones: json['habitaciones'],
      descripcion: json['descripcion'],
      fotos: List<String>.from(json['fotos']),
      ubicacion: json['ubicacion'],
      reglasUso: List<String>.from(json['reglasUso']),
      amenidades: List<String>.from(json['amenidades']),
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precioPorNoche': precioPorNoche,
      'maxPersonas': maxPersonas,
      'habitaciones': habitaciones,
      'descripcion': descripcion,
      'fotos': fotos,
      'ubicacion': ubicacion,
      'reglasUso': reglasUso,
      'amenidades': amenidades,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}
