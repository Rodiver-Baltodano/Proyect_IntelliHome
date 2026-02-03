class Pago {
  final String pagoId;
  final String reservationId;
  final String userId;
  final String propertyId;
  final String nombreCasa;
  final double montoArrendamiento;
  final double comision;
  final double iva;
  final double ajuste;
  final double total;
  final DateTime fecha;

  Pago({
    required this.pagoId,
    required this.reservationId,
    required this.userId,
    required this.propertyId,
    required this.nombreCasa,
    required this.montoArrendamiento,
    required this.comision,
    required this.iva,
    required this.ajuste,
    required this.total,
    required this.fecha,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      pagoId: json['pagoId'] as String,
      reservationId: json['reservationId'] as String,
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String,
      nombreCasa: json['nombreCasa'] as String? ?? '',
      montoArrendamiento: (json['montoArrendamiento'] as num).toDouble(),
      comision: (json['comision'] as num).toDouble(),
      iva: (json['iva'] as num).toDouble(),
      ajuste: (json['ajuste'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagoId': pagoId,
      'reservationId': reservationId,
      'userId': userId,
      'propertyId': propertyId,
      'nombreCasa': nombreCasa,
      'montoArrendamiento': montoArrendamiento,
      'comision': comision,
      'iva': iva,
      'ajuste': ajuste,
      'total': total,
      'fecha': fecha.toIso8601String(),
    };
  }
}
