/// Modelo de Reserva para IntelliHome
/// 
/// Representa una reserva de propiedad con su estado y acceso domótico
class Reserva {
  /// ID único de la reserva
  final String reservationId;

  /// Estado de la reserva: PENDING, CONFIRMED, CANCELLED, COMPLETED
  final String status;

  /// Fecha de inicio de la reserva
  final DateTime startDate;

  /// Fecha de fin de la reserva
  final DateTime endDate;

  /// ID de la propiedad reservada
  final String propertyId;

  /// Indica si tiene acceso a la domótica de la propiedad
  final bool accessDomotics;

  /// Constructor
  Reserva({
    required this.reservationId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.propertyId,
    this.accessDomotics = false,
  });

  /// Constructor desde JSON
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      reservationId: json['reservationId'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      propertyId: json['propertyId'] as String,
      accessDomotics: json['accessDomotics'] as bool? ?? false,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'reservationId': reservationId,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'propertyId': propertyId,
      'accessDomotics': accessDomotics,
    };
  }

  /// Copia de la reserva con campos modificados
  Reserva copyWith({
    String? reservationId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? propertyId,
    bool? accessDomotics,
  }) {
    return Reserva(
      reservationId: reservationId ?? this.reservationId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      propertyId: propertyId ?? this.propertyId,
      accessDomotics: accessDomotics ?? this.accessDomotics,
    );
  }

  @override
  String toString() {
    return 'Reserva(id: $reservationId, status: $status, property: $propertyId, '
        'dates: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}, '
        'domotics: $accessDomotics)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reserva && other.reservationId == reservationId;
  }

  @override
  int get hashCode => reservationId.hashCode;
}

/// Estados posibles de una reserva
class ReservaStatus {
  static const String pending = 'PENDING';
  static const String confirmed = 'CONFIRMED';
  static const String cancelled = 'CANCELLED';
  static const String completed = 'COMPLETED';

  /// Verifica si un estado es válido
  static bool isValid(String status) {
    return [pending, confirmed, cancelled, completed].contains(status);
  }
}
