class Casa {
  final String id;
  final String nombre;
  final double precioPorNoche;
  final int maxPersonas;
  final int habitaciones;
  final String descripcion;
  final List<String> fotos;
  final String ubicacion;
  final String reglasUso;
  final DateTime fechaRegistro;
  final List<int> amenidades; // IDs 1-32
  final List<DateTime> fechasNoDisponibles;

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
    required this.fechaRegistro,
    required this.amenidades,
    required this.fechasNoDisponibles,
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
      reglasUso: () {
        final raw = json['reglasUso'];
        if (raw is String) return raw;
        if (raw is List) {
          return raw.map((e) => e.toString()).join('\n');
        }
        return '';
      }(),
      amenidades: List<int>.from(json['amenidades']),
      fechasNoDisponibles: (json['fechasNoDisponibles'] as List<dynamic>)
          .map((f) => DateTime.parse(f))
          .toList(),
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
      'fechasNoDisponibles':
          fechasNoDisponibles.map((f) => f.toIso8601String()).toList(),
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}
